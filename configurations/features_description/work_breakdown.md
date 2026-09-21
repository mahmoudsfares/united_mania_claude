# Work breakdown — sprints, tasks, subtasks

The app is two screens: a **news feed** and a **news details** page. Their behaviour is specified in
[`news_feed.md`](news_feed.md) and [`news_details.md`](news_details.md). This file says in what
order to build them.

---

## How to use this file

Work **one subtask at a time**, top to bottom. For each subtask:

1. Read its entry here, and the part of the feature spec it points at.
2. Write its tests first and watch them fail.
3. Implement the smallest thing that makes them pass.
4. Run `flutter analyze` and the full test suite — both clean.
5. Write `configurations/reports/<sprint>.<task>.<subtask>.md` in simple English.
6. **Stop.** Do not start the next subtask unasked.

**Independence rule.** Every subtask below is self-contained: it compiles, runs, and passes its own
tests using only what earlier subtasks produced. Nothing depends on work scheduled later. While
implementing one, never create a file, parameter, or abstraction whose only purpose is to serve a
later subtask — build it when its own subtask arrives. There is exactly one exception, recorded at
2.1.2: its test was rewritten against the 2.1.3 fixture after the mock-repo-first rule was added.

**Mock repo before real repo.** CLAUDE.md §6 — a feature's mock repo is built first, because it
owns the fake payload that the real repo's tests are written against. In a later feature, the mock
repo subtask therefore comes before the repo subtask.

**Where tests live.** Unit tests mirror `lib/` under `test/`. End-to-end tests live in
`integration_test/` and always run against the mock repo, never the live API. Subtasks in Sprint 1
have no UI, so they carry unit tests only; the end-to-end requirement starts at 2.5.1, the first
subtask that puts a screen on the device.

---

## Sprint 1 — Foundation

No UI. Builds the `core/` layer every feature will sit on. At the end of this sprint the app still
shows nothing, and that is expected.

### Task 1.1 — Project setup

#### 1.1.1 — Dependencies, lints, test harness

**Goal.** Make the project ready to build and test under the project rules.

**Do.**
- Add to `pubspec.yaml` dependencies: `dio`, `flutter_bloc`, `equatable`, `intl`, `url_launcher`.
- Add to dev dependencies: `bloc_test`, `mocktail`, `http_mock_adapter`, and `integration_test`
  (`sdk: flutter`).
- Add the `assets/` entry to `pubspec.yaml` and create `assets/images/` with the image placeholder
  asset used when `urlToImage` is null.
- In `analysis_options.yaml`, turn on `always_specify_types` so the explicit-type rule (CLAUDE.md
  §4) is enforced by the analyzer rather than by eye. Make sure `omit_local_variable_types` is not
  also enabled — the two contradict each other.
- Delete the `flutter create` sample: strip `lib/main.dart` to a bare `runApp` of an empty
  `MaterialApp`, and delete `test/widget_test.dart` (it tests the counter app that no longer
  exists). Do not add a theme or routes here — those arrive in 1.2.1 and 2.5.1.
- Create `test/` and `integration_test/` with one smoke test each that pumps the empty app.

**Tests.** The two smoke tests.

**Done when.** `flutter pub get`, `flutter analyze` with zero issues, `flutter test` green, and the
integration smoke test green on an emulator.

---

### Task 1.2 — Utils and theme

#### 1.2.1 — Colours and app theme

**Goal.** The red-and-white visual identity, defined once.

**Do.** `core/utils/app_colors.dart` — the red primary, its accents, the surface and error colours,
and white for text. `core/utils/app_theme.dart` — a `ThemeData` built from those colours, with the
text theme set to white. No widget anywhere may declare a colour after this subtask.

**Tests.** Unit: the theme's `colorScheme.primary` is the red constant, and the body text style is
white. Widget: pump a `MaterialApp` with the theme and a `Text`, assert the resolved colour is
white on the red surface.

**Done when.** Tests pass and no colour literal exists outside `app_colors.dart`.

#### 1.2.2 — Strings, error messages, route names, json keys

**Goal.** Remove the need to hardcode any value anywhere.

**Do.** In `core/utils/`:
- `app_strings.dart` — every visible label: app title, "Retry", "Read the full article", the
  no-articles message, section labels.
- `app_error_messages.dart` — the user-facing text for each failure in
  [`news_feed.md` §2](news_feed.md): no internet, timeout, invalid key, rate limited, server error,
  generic, plus `noArticleLink` and `couldNotOpenLink` for the details screen.
- `routes.dart` — `home` and `newsDetails` route name constants.
- `json_keys.dart` — every key read from the API response: `status`, `articles`, `source`, `id`,
  `name`, `author`, `title`, `description`, `url`, `urlToImage`, `publishedAt`, `content`,
  `message`.

**Tests.** Unit: the constants are non-empty and the route names are unique. These are thin tests
by design — their value is that the files exist and are the only source of these values.

**Done when.** Tests pass.

#### 1.2.3 — Date formatter

**Goal.** Turn `"2026-09-15T12:06:44Z"` into something a reader wants to see.

**Do.** `core/utils/date_formatter.dart` — one static method taking `String?` and returning a
display date (`d MMM yyyy`, e.g. `15 Sep 2026`). Null, empty, and unparseable input all return an
empty string rather than throwing.

**Tests.** Unit: a valid ISO-8601 timestamp formats correctly; `null`, `""`, and `"not a date"`
each return `""`. Do not hardcode a local-time string in the assertion — the test would then pass
only in your timezone; build the expectation from the same parse the formatter performs.

**Done when.** Tests pass.

---

### Task 1.3 — Networking

#### 1.3.1 — `StateResource<T>`

**Goal.** The single result wrapper used by every repo and cubit.

**Do.** `core/networking/state_resource.dart`. Four constructors — init, loading, success(data),
error(message) — backed by a private status field. Properties `data` and `error`; getters
`isInit`, `isLoading`, `isSuccess`, `isError`. Extends `Equatable` so cubit states compare by
value.

**Tests.** Unit: each constructor sets exactly one getter to true and the rest to false; `success`
carries its data and a null error; `error` carries its message and null data; two instances built
the same way are equal.

**Done when.** Tests pass.

#### 1.3.2 — `NetworkErrorHandler`

**Goal.** One place that turns a thrown failure into an error `StateResource`.

**Do.** `core/networking/network_error_handler.dart`. Takes a `DioException` (and any other
`Object`, for safety) and returns `StateResource<T>.error(...)`. Map: the three timeout types,
`connectionError`, and `cancel` to a fixed message from `AppErrorMessages`; `badResponse` by status
code — 401, 426, 429, and 5xx each to their own fixed `AppErrorMessages` constant, since each is one
well-understood condition — and an `unknown` fallback to the generic message. **400 is the
exception**: read the API body's own `message` (`JsonKeys.message`) and show it as-is, since it
describes whatever parameter happened to be missing; fall back to the generic message only when the
body carries no usable string there.

**Tests.** Unit: one test per branch, asserting the returned resource is an error carrying the
expected constant; for 400, cover a body with a usable message and the fallback when it has none.

**Done when.** Tests pass and every branch is covered.

#### 1.3.3 — `ApiEndpoints`, `DioInterceptor`, `AppDioClient`

**Goal.** The one door all HTTP traffic goes through.

**Do.**
- `api_endpoints.dart` — `static const String` only: base URL, the `everything` path, the api key,
  and the `q` / `sortBy` / `language` query values from [`news_feed.md` §2](news_feed.md). No logic.
- `dio_interceptor.dart` — attaches the api key to every request's query parameters, and logs
  request and response in debug builds only.
- `app_dio_client.dart` — wraps a single `Dio` instance with base URL, timeouts, and the
  interceptor. Exposes `get(path, {queryParameters})`. It does not catch errors; repos do that.

**Tests.** Unit with `http_mock_adapter`: a 200 returns the decoded body; the interceptor puts the
api key on the outgoing request; a 401 and a timeout propagate as `DioException` rather than being
swallowed.

**Done when.** Tests pass. No test in this subtask hits the live API.

---

## Sprint 2 — News feed

Spec: [`news_feed.md`](news_feed.md). Ends with a working home screen listing real articles,
paginated via infinite scroll.

### Task 2.1 — Data

#### 2.1.1 — `Article` and `ArticleSource` models

**Goal.** Parse the API payload safely.

**Do.** `lib/features/news_feed/models/`. Both models plain data classes with `fromJson` and
`toJson`, reading keys from `JsonKeys`. **Every field is `String?`** — see
[`news_feed.md` §2](news_feed.md); the API returns nulls freely.

**Tests.** Unit: parse the real sample payload recorded in the spec; parse a payload where every
field is null without throwing; round-trip `toJson(fromJson(x)) == x`; a missing `source` object
does not crash.

**Done when.** Tests pass.

#### 2.1.2 — `NewsFeedRepo`

**Goal.** Fetch and parse the feed.

**Do.** `business_logic/news_feed_repo.dart`. One method,
`Future<StateResource<List<Article>>> getNews()`. Calls `AppDioClient.get` with the endpoint and
query values from `ApiEndpoints`, maps the `articles` array to `Article` objects, returns a success
resource. Catches failures and returns `networkErrorHandler(...)`'s result — it never builds an
error state by hand. Takes the dio client through its constructor so tests can inject a mock.

**Tests.** Unit with a mocked client, covering the whole repo scenario checklist in CLAUDE.md §7 —
the two transport failures, the 200 contract body, the eight 400 variants, the other documented
status codes (404, 500, 401, 426, 429), and the malformed-200 variants. Every payload comes from
`NewsFeedMockRepo`'s exposed fixture; the test file builds no data of its own. Because every
`Article` field is `String?`, checklist items 20–22 are read against what the payload genuinely
requires — the `articles` key being present, and each entry being an object.

**Done when.** Tests pass.

**Ordering note.** This subtask shipped before the mock-repo-first rule (CLAUDE.md §6) existed, so
`NewsFeedRepo` was written ahead of `NewsFeedMockRepo`. Its test was rewritten afterwards to read
from the fixture, and does not compile until 2.1.3 lands — the fail-first step, out of its usual
place. Every repo after this one is built mock first.

#### 2.1.3 — `NewsFeedMockRepo`

**Goal.** Run and test the app without spending the 100-request daily quota, and own the feature's
only copy of the fake payload.

**Do.** `business_logic/news_feed_mock_repo.dart`. Same public shape as the real repo, returning
the same `StateResource`. A constructor flag makes it return an error resource instead.

It exposes two fixtures, which are what `news_feed_repo_test.dart` already reads:

- `static const Map<String, dynamic> successResponseBody` — `JsonKeys.status` plus
  `JsonKeys.articles`, a list of ten article maps whose keys all come from `JsonKeys`. No
  `totalResults`: `JsonKeys` has no constant for it and nothing in the app reads it.
- `static const Map<String, dynamic> errorResponseBody` — `JsonKeys.status` plus
  `JsonKeys.message`, the human text a 400 carries.

`getNews()` waits one second, then parses `successResponseBody` through `Article.fromJson` rather
than constructing `Article` objects by hand, so the runtime data and the test data are the same
values. In failure mode it returns `StateResource.error` carrying
`errorResponseBody[JsonKeys.message]`.

The ten articles include the three awkward cases listed in
[`news_feed.md` §5](news_feed.md): a null `urlToImage`, a `"[Removed]"` title, and a null `author`
with a null `source.id`.

**Tests.** Unit: the success path returns ten articles after the delay; the failure flag returns an
error resource carrying the fixture's message; the fake data contains the three awkward cases the
UI tests rely on; `successResponseBody` parses through `Article.fromJson` without throwing.

**Done when.** Tests pass — including `news_feed_repo_test.dart`, which turns green here.

---

### Task 2.2 — Logic

#### 2.2.1 — `NewsFeedCubit` and `NewsFeedState`

**Goal.** Drive the feed's states.

**Do.**
- `news_feed_state.dart` — `typedef NewsFeedState = StateResource<List<Article>>;`. The feed has one
  piece of state and `StateResource` already models it; a wrapper class would add nothing.
- `news_feed_cubit.dart` — `Cubit<NewsFeedState>` starting at init, with `getNews()` emitting
  loading and then whatever the repo returned. The repo arrives through the constructor. No
  widgets, no `BuildContext`.

**Tests.** Unit with `bloc_test`: `getNews()` emits loading → success when the repo succeeds, and
loading → error when it fails, using both a mocked repo and the real `NewsFeedMockRepo`.

**Done when.** Tests pass.

---

### Task 2.3 — Shared widgets

Just one subtask. It used to be paired with the screen and the card under a single "Task 2.3 —
UI", but those two need pagination (Task 2.4) to exist first and this one doesn't — see Task 2.5.

#### 2.3.1 — Shared widgets

**Goal.** The three pieces both screens will use.

**Do.** In `core/shared_widgets/`:
- `app_network_image.dart` — takes a nullable url. Shows the `assets/images` placeholder when the
  url is null or empty, a loading indicator while fetching, and the same placeholder if the fetch
  fails. Uses `Image.network`; no caching package is needed for two screens.
- `app_loader.dart` — a centred progress indicator in the theme's colours.
- `app_error_view.dart` — a message plus a Retry button, taking the message and an `onRetry`
  callback.

**Tests.** Widget: the image shows the placeholder for null, empty, and failing urls, and the image
for a good one; the error view renders the given message and fires `onRetry` when tapped.

**Done when.** Tests pass.

---

### Task 2.4 — Pagination

Added after 2.2.1 shipped, once real usage made clear the feed needed more than one page. Its three
subtasks are built and reported before the rest of the feed's UI (Task 2.5) — 2.3.1 (shared
widgets) does not need them, but 2.5.1 (the screen) is written against the paginated cubit from the
start rather than being retrofitted. See the dependency map.

#### 2.4.1 — Paginate `NewsFeedMockRepo`

**Goal.** Serve fake data page by page, so 2.4.2's and 2.4.3's tests have something concrete to run
against — the mock repo is extended first, same as CLAUDE.md §6 for a repo built from scratch.

**Do.** `getNews()` becomes `getNews({int page = 1})` — defaulting to page 1, matching NewsAPI's
own default for the parameter, so `NewsFeedCubit`'s existing zero-argument call (unchanged until
2.4.3) keeps compiling and behaving exactly as before. Page 1 returns the existing ten
articles (`successResponseBody`, unchanged). Page 2 returns four more articles, in a new
`static const Map<String, dynamic> successResponseBodyPageTwo` fixture built the same way —
`JsonKeys.status` plus a `JsonKeys.articles` list, keys from `JsonKeys`, values invented. Page 3
and beyond return `StateResource.success` with an empty list; there is no fixture to build for
this, since an empty `articles` array has no parsing edge case. `getNews()` still waits one second
and still parses each fixture through `Article.fromJson` rather than building `Article` objects by
hand. The `returnError` flag still returns `errorResponseBody`'s message regardless of which page
was requested.

**Tests.** Unit: `getNews(page: 1)` returns the original ten articles; `getNews(page: 2)` returns
the four new ones; `getNews(page: 3)` returns an empty success list; the error flag still returns
the fixture message for at least two different pages; `successResponseBodyPageTwo` parses through
`Article.fromJson` without throwing.

**Done when.** Tests pass.

#### 2.4.2 — Paginate `NewsFeedRepo`

**Goal.** Request a specific page from the real API.

**Do.** `getNews()` becomes `getNews({int page = 1})`, the same default-parameter shape as 2.4.1,
for the same reason — it keeps compiling against the cubit unchanged until 2.4.3. Add
`ApiEndpoints.pageQueryParam`
(`'page'`) and `ApiEndpoints.pageSizeQueryParam` (`'pageSize'`) — `static const String`, the same
pattern as the existing query-param-name constants. The page size value itself is an `int`, so it
does not belong in `ApiEndpoints` (CLAUDE.md §2: "static const String values only"); add
`static const int pageSize = 10` on `NewsFeedRepo` and send it as the `pageSize` query value
alongside the requested `page`. Parsing and error handling are unchanged from 2.1.2.

**Tests.** Every existing scenario-checklist call site is updated to pass a page (`page: 1`) — the
scenarios are page-independent, so behaviour does not change. Add a test that `getNews(page: 1)`
sends `page=1` and `pageSize=10`, and that `getNews(page: 2)` sends `page=2` — proving the page
number is forwarded rather than hardcoded. Data continues to come from `NewsFeedMockRepo`'s
fixtures, now covering both of its pages.

**Done when.** Tests pass.

#### 2.4.3 — Paginate `NewsFeedCubit` and `NewsFeedState`

**Goal.** Track the current page, load more on request, and know when to stop.

**Do.**
- `news_feed_state.dart` — `NewsFeedState` stops being a bare typedef and becomes a small
  `Equatable` class wrapping `StateResource<List<Article>>` plus two flags: `isLoadingNextPage` and
  `hasReachedMax`. It exposes the same `isInit` / `isLoading` / `isSuccess` / `isError` / `data` /
  `error` getters as before, delegating to the wrapped resource, plus `copyWith`.
- `news_feed_cubit.dart` — `getNews()` keeps its current meaning (page 1 / refresh): it resets the
  tracked page to 1 and behaves exactly as before. A new `getNextPage()` requests
  `currentPage + 1`, guarded so it does nothing if a load is already in flight, `hasReachedMax` is
  already true, or the first page has not loaded successfully yet. On a successful, non-empty
  response it appends the new articles to the existing list and advances the tracked page. On an
  empty response it sets `hasReachedMax` instead of appending anything. On a failed response it
  clears the loading flag and leaves the existing list untouched, so a further scroll simply
  retries the same page.

**Tests.** Unit with `bloc_test`, both with a mocked repo and the real (now two-page)
`NewsFeedMockRepo`: `getNews()` still emits loading → success / loading → error unchanged;
`getNextPage()` after a successful first page appends the second page's articles and leaves
`hasReachedMax` false; `getNextPage()` once the repo returns an empty page sets `hasReachedMax`
true without changing the article list; `getNextPage()` is a no-op (repo not called again) once
`hasReachedMax` is true or while a load is already in flight; `getNextPage()` on a failed request
turns the loading flag off and keeps the current articles.

**Done when.** Tests pass.

---

### Task 2.5 — UI

Originally laid out as `2.3.2`/`2.3.3`, right after the shared widgets. Moved here, after
Pagination, because the screen (2.5.1) needs the paginated cubit (2.4.3) to exist first, and a
subtask must not depend on one numbered after it — see the dependency map.

#### 2.5.1 — App shell and the first working screen

**Goal.** The app launches and lists articles. The first end-to-end test. Depends on 2.4.3, not
directly on 2.2.1 — by the time this subtask starts, the cubit already paginates.

**Do.**
- `core/di/app_di.dart` — static singletons. A getter that builds the feed cubit with its repo, and
  a matching dispose method that closes the cubit and clears the singleton. Swapping
  `NewsFeedRepo` for `NewsFeedMockRepo` must be a one-line edit in this file.
- `core/routing/app_router.dart` — `generateRoute` with a case for `Routes.home` only. The details
  route is not added here; it arrives with the screen that needs it, in 3.1.1. The default case
  returns a simple "route not found" scaffold.
- `lib/main.dart` — `MaterialApp` with `AppTheme`, `onGenerateRoute`, and `initialRoute`.
- `news_feed_screen.dart` — a `StatefulWidget`, because it owns a lifecycle: `initState` calls
  `getNews()`, `dispose` calls `AppDi.disposeNewsFeed()`, honouring the disposal rule in CLAUDE.md
  §2. The `BlocBuilder` wraps **only the `Scaffold` body**, never the `AppBar`. Render the four
  states from [`news_feed.md` §4](news_feed.md) — loader, error view, empty message, and a plain
  `ListView` of titles. A `ScrollController` calls `getNextPage()` when the scroll position nears
  the end of the list; when `isLoadingNextPage` is true the list's last row is a small loading
  indicator. Card styling comes next, in 2.5.2.

**Tests.** Widget: each of the four states renders the right thing; the loading-more row appears at
the end of the list when `isLoadingNextPage` is true and is absent otherwise.
End-to-end with the mock repo: the app launches, shows the loader, then ten rows; scrolling to the
bottom loads four more (fourteen total) and scrolling further adds no more once the mock's pages
are exhausted; in failure mode it shows the message and Retry reloads into the list.

**Done when.** Tests pass and the app runs on a device against the mock repo.

#### 2.5.2 — The article card

**Goal.** Make the list look like a news feed.

**Do.** Replace the plain rows with a card showing the image via `AppNetworkImage`, the title, and
the source name with the date from `DateFormatter`. A null `author` or `source.name` must not leave
an empty line. Keep the card as a private widget in `news_feed_screen.dart` — the project structure
has no per-feature `widgets/` directory, and a widget used on one screen does not belong in
`core/shared_widgets`. Give the card a real tap target; it does nothing yet, since the details
screen arrives in 3.1.1.

**Tests.** Widget: the card renders title, source, and formatted date; an article with a null image
shows the placeholder; an article with a null source renders without a blank row.
End-to-end: ten cards, each showing its title and image or placeholder.

**Done when.** Tests pass.

---

## Sprint 3 — News details

Spec: [`news_details.md`](news_details.md).

### Task 3.1 — Details screen

#### 3.1.1 — Navigation and the details route

**Goal.** Tapping a card opens a details screen showing that article.

**Do.** Add `Routes.newsDetails` to `generateRoute`, reading the `Article` from
`settings.arguments`. Handle a missing or wrong-typed argument by returning the "route not found"
scaffold instead of crashing. Create `news_details_screen.dart` showing the title only — a
`StatelessWidget` for now, with no cubit, because nothing on it is asynchronous yet. Wire the
card's tap in the feed to push the route with the tapped article.

**Tests.** Widget: the screen renders the title of the article it is given.
End-to-end: tap the first card, land on details, see that article's title; back returns to the feed.

**Done when.** Tests pass.

#### 3.1.2 — Details content

**Goal.** Show the whole article payload.

**Do.** Build the scrollable layout from [`news_details.md` §3](news_details.md): image, title,
byline, date, description, content. Omit any section whose field is null rather than rendering an
empty box. Strip the API's trailing `"… [+13602 chars]"` counter off `content` — it is noise from
the free plan's truncation, not part of the article.

**Tests.** Widget: a full article renders all six sections; an article with null description and
content renders neither, and does not overflow; the truncation counter is stripped; a null
`urlToImage` shows the placeholder.

**Done when.** Tests pass.

#### 3.1.3 — Open in browser

**Goal.** The hyperlink that reaches the full article.

**Do.**
- `core/apis/url_launcher_api.dart` — a thin wrapper over `url_launcher`, so the cubit is testable
  without a platform channel.
- `news_details_cubit.dart` and `news_details_state.dart` —
  `typedef NewsDetailsState = StateResource<void>;`, with `openArticle(String? url)` following the
  table in [`news_details.md` §4](news_details.md). The screen becomes stateful so it can dispose
  the cubit through `AppDi`, matching 2.5.1.
- The hyperlink itself, with a `BlocListener` around **only the link** that shows the failure
  snackbar.

**Tests.** Unit: a valid url calls the api once with `LaunchMode.externalApplication` and emits
success; null and empty urls emit an error and never call the api; a throwing or false-returning
api emits an error.
End-to-end with a fake launcher: tapping the link passes that article's url; a failing launcher
shows the snackbar.

**Done when.** Tests pass. Both screens are complete.

---

## Sprint 4 — Polish

Optional. The app is usable without this sprint; both subtasks address real rough edges in the live
data.

#### 4.1.1 — Pull to refresh

**Do.** Wrap the feed list in a `RefreshIndicator` calling `getNews()`. The empty state must also
be pullable, otherwise an empty feed is a dead end.

**Tests.** Widget: the pull gesture calls `getNews()`. End-to-end: pull, see the loader, see the
refreshed list.

#### 4.1.2 — Drop removed articles

**Do.** NewsAPI returns placeholder entries whose title, description, and content are the literal
string `"[Removed]"`. Filter them out in both repos, in one place, before the list reaches the
cubit.

**Tests.** Unit: a payload of three articles where one is `"[Removed]"` yields two; a payload of
only removed articles yields an empty list, which the UI already renders as the empty state.

---

## Dependency map

Each subtask may use everything above it and nothing below it.

```
1.1.1  setup
 ├─ 1.2.1  colours + theme
 ├─ 1.2.2  strings, errors, routes, json keys
 │   └─ 1.2.3  date formatter
 │       └─ 1.3.1  StateResource
 │           └─ 1.3.2  NetworkErrorHandler
 │               └─ 1.3.3  ApiEndpoints + interceptor + dio client
 │                   └─ 2.1.1  models
 │                       └─ 2.1.2  repo            ← its test reads 2.1.3's fixture
 │                           └─ 2.1.3  mock repo
 │                               └─ 2.2.1  cubit + state
 │                                   └─ 2.4.1  mock repo pagination
 │                                       └─ 2.4.2  repo pagination
 │                                           └─ 2.4.3  cubit + state pagination (*)
 └─ 2.3.1  shared widgets (*)
     └─ 2.5.1  di + routing + main + feed screen      ← first end-to-end test; (*) needs both
         └─ 2.5.2  article card
             └─ 3.1.1  details route + navigation
                 └─ 3.1.2  details content
                     └─ 3.1.3  url launcher + hyperlink
                         ├─ 4.1.1  pull to refresh
                         └─ 4.1.2  drop removed articles
```

---

## Open decisions

Two choices were made to keep the build moving. Either can be reversed; both are worth a look
before Sprint 2 starts.

1. **Feature-local widgets live inside the screen file** as private classes (2.5.2). The project
   structure defines a feature as screen + `models/` + `business_logic/`, with no `widgets/`
   directory, and `core/shared_widgets` is reserved for widgets used in more than one place. If a
   feature's screen file grows uncomfortable, adding `features/<feature>/widgets/` to the structure
   is the alternative.
2. **Decided in 1.3.3: the api key is a hardcoded constant in `api_endpoints.dart`.** The
   `--dart-define=NEWS_API_KEY=...` alternative was considered and declined, so the key is
   committed to the repository. Revisit before the repo is made public or shared outside the team.
