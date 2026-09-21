# united_mania_claude — Project Instructions

Flutter app. These rules are binding for every change. Read them before writing code, and follow
them even when a different pattern would be "more standard".

---

## 1. Project structure

```
united_mania_claude/
├── assets/                          # images, fonts (if any)
├── configurations/                  # project documentation, not shipped code
│   ├── project_structure/           # this document
│   ├── features_description/        # feature specs + the sprint work breakdown
│   └── reports/                     # one report per subtask: <sprint>.<task>.<subtask>.md
└── lib/
    ├── core/
    │   ├── apis/                    # e.g. notifications_api.dart
    │   ├── di/                      # single file, manual DI, static singletons
    │   ├── networking/
    │   │   ├── app_dio_client.dart
    │   │   ├── dio_interceptor.dart
    │   │   ├── api_endpoints.dart   # static const endpoint strings only
    │   │   ├── state_resource.dart
    │   │   └── network_error_handler.dart
    │   ├── routing/                 # generateRoute + route name constants
    │   ├── utils/                   # colors, strings, map keys, route names, formatters...
    │   └── shared_widgets/          # any widget used in more than one place
    └── features/
        └── <feature_name>/
            ├── <feature_name>_screen.dart
            ├── models/
            └── business_logic/
                ├── <feature_name>_cubit.dart
                ├── <feature_name>_state.dart
                └── <feature_name>_repo.dart
```

File and directory names are `snake_case`. Class names are `PascalCase`.

---

## 2. Layer responsibilities

### `core/apis`
Thin, feature-agnostic service wrappers (e.g. `notifications_api`) — push notifications, local
storage, permissions. Not HTTP call sites for features; those live in repos.

### `core/di`
One file holding manual dependency injection as **static singletons**. No `get_it`, no service
locator package, no code generation. Registering a mock repo instead of the real one must be a
one-line change here (see §6). **Dispose of the cubit and the repo when the screen they are bound
to is dismissed** — the singletons file must expose the creation and the teardown side by side, so
nothing outlives its screen.

### `core/networking`
- `app_dio_client` — the single Dio wrapper. All HTTP traffic goes through it.
- `dio_interceptor` — headers, auth token, logging.
- `api_endpoints` — `static const String` values only. No logic.
- `state_resource` — the single state/result wrapper used by repos and cubits:
  - properties: `data`, `error`
  - getters: `isLoading`, `isInit`, `isSuccess`, `isError`
- `network_error_handler` — called **from the repo** when a request fails, and returns the error
  `StateResource`. Repos never build error states by hand.

### `core/routing`
`generateRoute` switch + route name constants. Screens are not constructed anywhere else.

### `core/utils`
Colors, app strings, map keys, route names, static error messages, formatters, validators, and all
constants — enough that no value ever needs to be hardcoded anywhere else.

### `core/shared_widgets`
If a widget is (or will be) used in more than one place, it moves here. Never copy-paste a widget.

### `features/<feature>`
Screen + `models/` + `business_logic/` (cubit, state, repo). One feature = one directory.

---

## 3. Architecture rules

- **Cubit only** (no Bloc events), one cubit per feature.
- **Repo is concrete.** No use cases, no abstract repository + implementation pair, no
  `data/domain/presentation` split. The repo talks to `AppDioClient` directly and returns a
  `StateResource`.
- Call chain is exactly: `Screen → Cubit → Repo → AppDioClient`.
  The UI never touches Dio; models never touch Dio.
- Repos catch failures and return the error `StateResource` built by `network_error_handler`.
  Repos never assemble error states by hand.
- Cubits emit states; they contain no widgets and no `BuildContext`.
- Models are plain data classes with `fromJson` / `toJson`. No business logic, no code generation
  unless already present in the project.
- Single source of truth: one place owns each piece of state — no duplicated fields between cubit
  state and local widget state.
- **Scope builders tightly.** Wrap a `BlocBuilder` / `BlocListener` / `BlocConsumer` around the
  smallest widget subtree that actually reacts to the state. Never place one at the top of a
  screen to rebuild the whole tree.
- Cubits and repos are disposed with the screen that owns them (see `core/di`).

---

## 4. Coding rules

- **Always declare the type explicitly.** `final int x = 0;` — never `final x = 0;`.
  This applies to locals, fields, parameters, return types, closures, and generics.
- **Do not over-engineer.** The simplest structure that satisfies the rules above wins. No extra
  abstraction layers, no interface with a single implementation, no premature generalization.
- **DRY.** Repeated widget → `core/shared_widgets`. Repeated logic → `core/utils`.
  Repeated string / color / endpoint → its constants file.
- **Comments only for complicated logic.** No comments restating what the code says, no docblocks
  on obvious methods, no section banners.
- Respect SOLID and clean-code naming: intention-revealing names, small methods, one reason to
  change per class.
- `const` constructors wherever possible; prefer stateless widgets.
- No hardcoded strings, colors, URLs, map keys, or route names anywhere — pull them from
  `core/utils` / `api_endpoints`.

---

## 5. Theme

- Built from **red and its accents**; **white** for fonts.
- Defined once in `core/utils` (colors) plus the app theme. Widgets read from `Theme.of(context)`
  or the color constants — never an inline `Color(0xFF...)` in a feature file.

---

## 6. Mock repos

Every real repo has a mock twin that mimics the server response with fake data.

- **Write the mock repo first.** It comes before the real repo and before the real repo's tests,
  because it is what fixes the shape of the payload everything else is built against.
- Same public API as the real repo, returning the same `StateResource` shapes.
- Lives next to the real repo in the feature's `business_logic/` directory
  (`<feature>_mock_repo.dart`).
- **It owns the fake payload and exposes it.** The fake server response bodies are
  `static const Map<String, dynamic>` fields on the mock repo — one for the success body, one for
  the error body. The mock repo builds its own `StateResource` by parsing those same fields through
  the real models, so the data it serves at runtime and the data the tests assert against are the
  same values. There is one fake payload per feature and it lives here.
- Keys inside a fixture come from `core/utils/json_keys.dart`. The *values* are invented literals —
  that is what a fixture is — and the mock repo is the only place such literals are allowed.
- Includes a small artificial delay, and covers both success and failure paths so manual testing
  can exercise the error UI.
- Swapping real ↔ mock is a **single line change in `core/di`**. Nothing else in the app changes.

---

## 7. Testing — TDD is mandatory

Write the test first, watch it fail, then implement.

- **Unit tests** for every cubit, repo, util, formatter, and model (`fromJson` / `toJson`).
  Cubit tests assert the emitted `StateResource` sequence (loading → success, loading → error).
  Repo tests use a mocked Dio client and cover the scenario checklist below.
- **End-to-end / integration tests** for every feature flow — the user-visible path from screen
  interaction to rendered result, driven with the mock repos.
- Mirror the `lib/` structure under `test/` and `integration_test/`.
- No feature is done without both its unit tests and its end-to-end test passing.

### Test data comes from the mock repo

A test file never hand-builds a payload. No `articleJson(...)` helper, no literal response map, no
second copy of the fake data. Read the fixture the mock repo exposes (§6), and where a test needs a
broken variant, derive it from that fixture by copying and mutating it. When the fixture changes,
every test that depends on it changes with it — which is the point.

### Repo tests — the scenario checklist

Every repo method is tested against this list, with a mocked `AppDioClient`. A scenario that cannot
occur for a given endpoint is skipped, and the subtask report says which and why.

**Transport**

1. No internet connection
2. Connection timeout

**Success**

3. 200, good response body

**Client error**

4. 400, good response body
5. 400, empty response body
6. 400, null response body
7. 400, garbage response body
8. 400, empty error field
9. 400, null error field
10. 400, missing error field
11. 400, error field of an unexpected type

**Other status codes**

12. 404
13. 500

**200 with a body that breaks the contract**

14. 200, empty response body
15. 200, null response body
16. 200, garbage response body
17. 200, empty data field
18. 200, null data field
19. 200, data field of an unexpected type
20. 200, data with a null non-nullable field
21. 200, data missing a non-nullable field
22. 200, data with a field of an unexpected type

Add a case for every other status code the endpoint documents (204, 401, 426, 429, …). Where the
models make every field nullable, scenarios 20–22 apply to whatever *is* required — the envelope's
data key, and each entry being an object of the expected type — and the report records that reading.

---

## 8. Definition of done

Before reporting a task complete:

1. Tests were written first, and all tests pass.
2. Every variable has an explicit type.
3. No duplicated widget or logic; shared code moved to `core/`.
4. Repo returns `StateResource`; errors routed through `network_error_handler`.
5. The mock repo was written before the real repo, is swappable from `core/di`, and owns the
   feature's only fake payload.
6. Repo tests cover the §7 scenario checklist and take their data from the mock repo's fixture —
   no payload helpers or literal response maps in test files.
7. No stray strings, colors, endpoints, map keys, or route names outside their constants files.
8. Cubit and repo are disposed with their screen.
9. Builders/listeners wrap only the subtree that needs them.
10. No abstraction beyond what these instructions describe.
11. A subtask report was written to `configurations/reports/` (see §9).

---

## 9. `configurations/` — documentation and reports

Markdown only; nothing here is compiled or shipped.

- **`configurations/project_structure/`** — this document. It is the single source of truth for
  structure and rules; if a rule changes, change it here and nowhere else.
- **`configurations/features_description/`** — one file per feature (`<feature_name>.md`): what the
  feature does, its screens, its endpoints, its states. Plus `work_breakdown.md`, the sprint →
  task → subtask plan. Create or update these whenever a feature is added or its behaviour changes.
- **`configurations/reports/`** — one report per subtask, named `<sprint>.<task>.<subtask>.md`
  (e.g. `2.1.3.md`). Written in **simple English** when the subtask is finished: what was asked,
  what changed, what was tested, anything left open.

---

## 10. Working rhythm

Work proceeds **one subtask at a time**, in the order set by
`configurations/features_description/work_breakdown.md`.

1. Read the subtask's entry in the work breakdown before touching any code.
2. Write its unit tests (and its end-to-end test, once the app has UI). Ask me to run them, and
   watch them fail.
3. Implement the smallest thing that makes them pass.
4. Run `flutter analyze`, then ask me to run the full test suite. Both must be clean before the
   subtask is done.
5. Write the report to `configurations/reports/<sprint>.<task>.<subtask>.md`.

Rules while working a subtask:

- **Never build ahead.** Do not create files, parameters, or abstractions that only a later
  subtask will use. Every subtask must compile, run, and pass its own tests on its own.
- **Never reach forward.** A subtask may only depend on subtasks already completed.
- Every subtask leaves the repository green: `flutter analyze` clean, every test passing.
- **Never run `flutter pub get` or any test yourself.** When dependencies need fetching or
  tests need running, ask me to run it and wait for my result before continuing.
- Stop at the end of a subtask and report. Do not start the next one unasked.
