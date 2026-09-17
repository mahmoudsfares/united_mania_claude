# Feature — `news_details`

Shows one article in full, and opens the original web page in the device's browser.

Directory: `lib/features/news_details/`

---

## 1. Purpose

| | |
|---|---|
| Route | `Routes.newsDetails` |
| Argument | the tapped `Article` object, passed through `settings.arguments` |
| Screen | `news_details_screen.dart` → `NewsDetailsScreen` |
| Cubit | `NewsDetailsCubit` — one public method, `openArticle(String? url)` |
| Repo | **none** — see §2 |
| Models | reuses `Article` from `news_feed` |

---

## 2. Why this feature has no repo

The screen makes **no network call**. NewsAPI has no "fetch one article by id" endpoint, and the
list response already carries every field the details screen displays, so the `Article` travels as
a route argument and is rendered directly.

The one asynchronous action is opening the browser, which can fail (no browser installed, a `null`
or malformed `url`). That goes through `UrlLauncherApi` in `core/apis` — a thin wrapper over
`url_launcher` — and the call chain for this feature is:

```
NewsDetailsScreen → NewsDetailsCubit → UrlLauncherApi
```

`NewsDetailsCubit` emits a `StateResource<void>`, so the failure path reaches the user as a
snackbar instead of being swallowed. Tests inject a fake `UrlLauncherApi`; there is no mock repo
for this feature because there is no repo.

---

## 3. Screen content

Scrollable, in order:

1. **Image** — `urlToImage`, full width, fixed aspect ratio. Falls back to the shared placeholder
   when the field is `null` or the image fails to load.
2. **Title** — `title`, the largest text on the screen.
3. **Byline** — `author` and `source.name` on one line. When `author` is `null`, the source name
   stands alone; when both are `null`, the line is omitted entirely rather than left blank.
4. **Date** — `publishedAt`, run through `DateFormatter`.
5. **Description** — `description`. Omitted when `null`.
6. **Content** — `content`. This arrives **truncated** from the API (`"… [+13602 chars]"`), so the
   screen strips that trailing counter and shows the readable part only. Omitted when `null`.
7. **Hyperlink** — "Read the full article", styled as a link. This is the only way to read the
   whole piece, so it is visually prominent and always present.

Every string comes from `AppStrings`; every colour from the theme.

---

## 4. Opening the link

Tapping the hyperlink calls `NewsDetailsCubit.openArticle(article.url)`.

| situation | behaviour |
|---|---|
| `url` is `null` or empty | error state → snackbar `AppErrorMessages.noArticleLink`. The browser is never launched. |
| the launch succeeds | the page opens in the **external** browser (`LaunchMode.externalApplication`), not an in-app web view |
| the launch fails | error state → snackbar `AppErrorMessages.couldNotOpenLink` |

A `BlocListener` around the hyperlink alone shows the snackbar. The rest of the screen is static
and is not wrapped in any builder.

---

## 5. Tests

**Unit**

- `NewsDetailsCubit.openArticle` with a valid url → calls `UrlLauncherApi` once with
  `LaunchMode.externalApplication`, emits success
- with `null` and with `""` → emits error, and the api is **not** called
- when the api throws or returns `false` → emits error

**End-to-end**, driven by `NewsFeedMockRepo` and a fake `UrlLauncherApi`

- tap a card on the feed → details shows that article's title
- an article with `urlToImage: null` shows the placeholder, not a broken image
- an article with `author: null` shows the source alone, with no empty byline row
- tapping the hyperlink calls the launcher with that article's url
- a failing launcher shows the snackbar
