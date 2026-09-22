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
| Cubit | `NewsFeedCubit` — `getNews()` (page 1 / refresh) and `getNextPage()` (subsequent pages) |
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
| `page` | the requested page, starting at `1` |
| `pageSize` | `10` — fixed by `NewsFeedRepo.pageSize` |

The `fbclid` parameter from the original URL is **dropped** — it is Facebook click-tracking and the
API ignores it.

The `apiKey` is attached in `DioInterceptor`, not repeated at each call site.

### Pagination

`everything` is called once per page. `NewsFeedRepo.pageSize` is fixed at `10`; it lives on the
repo rather than in `ApiEndpoints`, since that file holds `static const String` values only.
`NewsFeedCubit` tracks the current page: `getNews()` always (re)starts at page 1, `getNextPage()`
requests `currentPage + 1`. A page whose `articles` array comes back **empty** means there is
nothing further — the cubit sets `hasReachedMax` and stops requesting more. This is the only signal
used; `totalResults` is still not read anywhere in the app (decided in 2.1.3).

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

Before either repo returns its list, articles whose `title` is the literal string `"[Removed]"` —
NewsAPI's placeholder for takedown content — are dropped, in one place shared by both repos, so the
cubit and the screen never see them.

| state | what the screen shows |
|---|---|
| `isInit` | nothing — the first frame before loading starts |
| `isLoading` | `AppLoader`, centred |
| `isSuccess`, list not empty | the scrollable list of article cards |
| `isSuccess`, list empty | `AppStrings.noArticles` message |
| `isError` | `AppErrorView` — the message from `StateResource.error` plus a **Retry** button that calls `getNews()` again |

### Loading more

Once the first page is showing, scrolling near the bottom of the list calls
`NewsFeedCubit.getNextPage()`. While that request is in flight, a small loading indicator is the
last row of the list — the existing articles stay put, the full-screen `AppLoader` from the table
above is not shown again. If the next page fails, the indicator is simply removed and the list is
left as is; scrolling to the bottom again retries. Once a page comes back empty, `hasReachedMax` is
true and no further scroll triggers a request.

### Filling the screen

A screen tall enough to show every row of a page without scrolling would otherwise never trigger
the scrolling behaviour above — there is nothing to scroll. So after any page loads successfully
(the first page or a later one), if the list still does not overflow the visible screen, the screen
requests the next page on its own, without waiting for a scroll gesture. This repeats — each
successful page is checked again once it renders — until either the list overflows (scrolling above
takes over from there) or a page comes back empty and `hasReachedMax` stops it. A failed next-page
request does not chain into another automatic request, only a successful one does, so a persistent
failure cannot turn into a rapid retry loop against the 100-requests-a-day quota — the failure
handling above still applies, and the next successful trigger, manual or automatic, retries the same
page.

Each card shows, top to bottom:

- the image from `urlToImage`, or the placeholder when it is `null` or fails to load
- the `title`
- the `source.name` and the `publishedAt` date, formatted by `DateFormatter`

Tapping a card pushes `Routes.newsDetails`, passing the tapped `Article` as the route argument.

The `BlocBuilder` wraps **only the body** of the `Scaffold`. The `AppBar` does not rebuild.

---

## 5. Mock repo

`NewsFeedMockRepo.getNews({int page = 1})` returns fake `Article` objects after a 1-second delay,
page by page: page 1 returns the original ten, page 2 returns four more, and page 3 onward returns
an empty list — the signal `NewsFeedCubit` uses to stop paging. The default keeps
`NewsFeedCubit`'s zero-argument call compiling unchanged until 2.4.3 rewrites it. Its fake data
deliberately includes:

- one article with `urlToImage: null` (exercises the placeholder)
- one article with `title: "[Removed]"` (exercises filtering)
- one article with `author: null` and `source.id: null`

A flag on the constructor makes it return an error `StateResource` instead, regardless of which
page was requested, so the error UI can be exercised by hand at any point in the scroll.

### It owns the feature's fake payload

Per CLAUDE.md §6, the fake data is not a list of hand-built `Article` objects — it is the fake
*server response*, held as `static const Map<String, dynamic>` fixtures:

| fixture | shape |
|---|---|
| `successResponseBody` | page 1 — `JsonKeys.status` + `JsonKeys.articles`, the ten article maps |
| `successResponseBodyPageTwo` | page 2 — `JsonKeys.status` + `JsonKeys.articles`, four more article maps |
| `errorResponseBody` | `JsonKeys.status` + `JsonKeys.message` — the human text a 400 carries |

`getNews()` parses the fixture for the requested page through `Article.fromJson` (page 3 and beyond
has no fixture to parse — there is no JSON edge case in an empty list, so it is returned directly),
and the failure flag returns `errorResponseBody[JsonKeys.message]`. These fixtures are what
`news_feed_repo_test.dart` reads, so the app and the tests run on the same values and there is only
one copy of the fake data. Keys come from `JsonKeys`; the values are invented literals, which is
allowed here and nowhere else.

---

## 6. Tests

**Unit**

- `Article.fromJson` / `toJson`, including an all-`null` payload
- `ArticleSource.fromJson` / `toJson`
- `NewsFeedRepo` with a mocked Dio client, against the full scenario checklist in CLAUDE.md §7: no
  internet and timeout; 200 with the contract body; the eight 400 variants (good body, empty, null,
  garbage, and an empty / null / missing / wrong-typed `message`); 404, 500, 401, 426, 429; and the
  malformed-200 variants (empty, null and garbage bodies; an `articles` field that is empty, null,
  wrong-typed, missing, or holding a null entry; an article field of the wrong type). Its data
  comes from `NewsFeedMockRepo`'s fixtures — the test file builds no payload of its own. Separately,
  that the requested `page` and the fixed `pageSize` are sent as query values, for more than one
  page number.
- `NewsFeedMockRepo`: page 1 parses all ten fixture articles (with the three awkward cases) through
  `Article.fromJson` and returns the nine that remain once the `"[Removed]"` one is filtered out,
  page 2 returns the four new ones, page 3 returns an empty list, the failure flag returns the
  fixture message regardless of page, and both success fixtures parse cleanly through
  `Article.fromJson`
- a shared filter dropping `"[Removed]"`-titled articles: three articles with one removed yields
  two, and a list of only removed articles yields an empty one
- `NewsFeedCubit`: `getNews()` emits loading → success, and loading → error; `getNextPage()` appends
  a successful next page and leaves `hasReachedMax` false, sets `hasReachedMax` on an empty page
  without touching the article list, is a no-op once `hasReachedMax` is true or while already
  loading a page, and leaves the current list untouched when the next page fails

**End-to-end**, driven by `NewsFeedMockRepo`

- app launches on the feed, loader appears, then 9 cards (the removed one dropped)
- scrolling to the bottom loads 4 more cards (13 total); scrolling further triggers no further
  loader once the mock's pages are exhausted
- tapping the first card opens the details screen
- error mode shows the message, and Retry reloads into the list
