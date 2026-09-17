# Feature — `news_feed` (home screen)

The app's entry screen. Shows a scrollable list of recent Manchester United news articles.
Tapping an article opens `news_details`.

Directory: `lib/features/news_feed/`

---

## 1. Purpose

| | |
|---|---|
| Route | `Routes.home` — the initial route |
| Screen | `news_feed_screen.dart` → `NewsFeedScreen` |
| Cubit | `NewsFeedCubit` — one public method, `getNews()` |
| Repo | `NewsFeedRepo` (real) / `NewsFeedMockRepo` (fake) |
| Models | `Article`, `ArticleSource` |
| Network | `GET everything` via `AppDioClient` |

---

## 2. API contract

### Request

| | |
|---|---|
| Base URL | `https://newsapi.org/v2/` → `ApiEndpoints.baseUrl` |
| Path | `everything` → `ApiEndpoints.everything` |
| Method | `GET` |

Query parameters — passed as a Dio `queryParameters` **map**, never as a hand-built URL string
(Dio handles the encoding of the spaces and the `|` characters):

| key | value |
|---|---|
| `q` | `manchester united\|man utd\|man united\|manchester utd` |
| `sortBy` | `publishedAt` |
| `language` | `en` |
| `apiKey` | the key constant |

The `fbclid` parameter from the original URL is **dropped** — it is Facebook click-tracking and the
API ignores it.

The `apiKey` is attached in `DioInterceptor`, not repeated at each call site.

### Success response — HTTP 200

```json
{
  "status": "ok",
  "totalResults": 4613,
  "articles": [ /* Article objects */ ]
}
```

### `Article` object

| field | type | notes |
|---|---|---|
| `source.id` | `String?` | very often `null` |
| `source.name` | `String?` | e.g. `"Yahoo Entertainment"` |
| `author` | `String?` | may be `null`, or several names comma-joined |
| `title` | `String?` | may be the literal string `"[Removed]"` |
| `description` | `String?` | short summary, may be `null` |
| `url` | `String?` | the article's web page — used by the browser link on details |
| `urlToImage` | `String?` | **frequently `null`** — the UI must handle it |
| `publishedAt` | `String?` | ISO-8601 UTC, e.g. `"2026-09-15T12:06:44Z"` |
| `content` | `String?` | **truncated** by the free plan, see §3 |

**Every field is nullable.** Model all of them as `String?` and fall back in the UI, never assume
a value is present.

### Error responses

Body: `{"status": "error", "code": "<code>", "message": "<human text>"}`

| HTTP | `code` | meaning |
|---|---|---|
| 400 | `parametersMissing` | a required query parameter is absent |
| 401 | `apiKeyInvalid` / `apiKeyMissing` | bad or absent key |
| 426 | `upgradeRequired` | plan limit hit |
| 429 | `rateLimited` | more than 100 requests in 24 h |
| 500 | `unexpectedError` | server side |

`NetworkErrorHandler` maps 401, 426, 429, and 5xx to their own fixed message from
`AppErrorMessages` — each is one well-understood condition, so the raw `message` field is never
shown for them. **400 is the exception**: it covers whatever query parameter happened to be
missing, so the body's own `message` (read via `JsonKeys.message`) is shown to the user as-is,
falling back to `AppErrorMessages.generic` only when the body carries no usable message.

---

## 3. Known constraints of the free plan

Verified against the live endpoint on 2026-09-16 — key valid, 4,613 results.

1. **`content` is truncated to roughly 200 characters**, ending in `"… [+13602 chars]"`.
   The full article text is not available from the API. This is the reason the details screen needs
   the browser hyperlink — it is the only way to read the whole piece.
2. **100 requests per day.** Use `NewsFeedMockRepo` for manual testing and for every automated
   test, so the quota is spent only on real runs.
3. **Development-only, CORS-blocked.** Requests from a browser are refused, so **Flutter web will
   not work**. Target Android and iOS.
4. **`q` matches the article body, not only the title**, so unrelated articles appear in the
   results (a live sample returned an MLS newsletter). This is the API behaving normally, not a bug.
5. **Decided in 1.3.3**: the API key is a plain string constant in `ApiEndpoints.apiKey`, so
   anyone with read access to the repo has it. The `--dart-define=NEWS_API_KEY=...` alternative
   was considered and declined. Revisit before the repo is made public or shared outside the team.

---

## 4. Screen behaviour

`NewsFeedCubit.getNews()` is called once when the screen is first built, and emits a
`StateResource<List<Article>>`.

| state | what the screen shows |
|---|---|
| `isInit` | nothing — the first frame before loading starts |
| `isLoading` | `AppLoader`, centred |
| `isSuccess`, list not empty | the scrollable list of article cards |
| `isSuccess`, list empty | `AppStrings.noArticles` message |
| `isError` | `AppErrorView` — the message from `StateResource.error` plus a **Retry** button that calls `getNews()` again |

Each card shows, top to bottom:

- the image from `urlToImage`, or the placeholder when it is `null` or fails to load
- the `title`
- the `source.name` and the `publishedAt` date, formatted by `DateFormatter`

Tapping a card pushes `Routes.newsDetails`, passing the tapped `Article` as the route argument.

The `BlocBuilder` wraps **only the body** of the `Scaffold`. The `AppBar` does not rebuild.

---

## 5. Mock repo

`NewsFeedMockRepo` returns a fixed list of 10 fake `Article` objects after a 1-second delay.
Its fake data deliberately includes:

- one article with `urlToImage: null` (exercises the placeholder)
- one article with `title: "[Removed]"` (exercises filtering)
- one article with `author: null` and `source.id: null`

A flag on the constructor makes it return an error `StateResource` instead, so the error UI can be
exercised by hand without unplugging the network.

---

## 6. Tests

**Unit**

- `Article.fromJson` / `toJson`, including an all-`null` payload
- `ArticleSource.fromJson` / `toJson`
- `NewsFeedRepo` with a mocked Dio client: 200 → success with parsed articles; 401, 429 and a
  timeout → the matching error `StateResource`
- `NewsFeedCubit`: emits loading → success, and loading → error

**End-to-end**, driven by `NewsFeedMockRepo`

- app launches on the feed, loader appears, then 10 cards
- tapping the first card opens the details screen
- error mode shows the message, and Retry reloads into the list
