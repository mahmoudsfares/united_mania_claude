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

- Same public API as the real repo, returning the same `StateResource` shapes.
- Lives next to the real repo in the feature's `business_logic/` directory
  (`<feature>_mock_repo.dart`).
- Includes a small artificial delay, and covers both success and failure paths so manual testing
  can exercise the error UI.
- Swapping real ↔ mock is a **single line change in `core/di`**. Nothing else in the app changes.

---

## 7. Testing — TDD is mandatory

Write the test first, watch it fail, then implement.

- **Unit tests** for every cubit, repo, util, formatter, and model (`fromJson` / `toJson`).
  Cubit tests assert the emitted `StateResource` sequence (loading → success, loading → error).
  Repo tests use a mocked Dio client and cover both success and failure.
- **End-to-end / integration tests** for every feature flow — the user-visible path from screen
  interaction to rendered result, driven with the mock repos.
- Mirror the `lib/` structure under `test/` and `integration_test/`.
- No feature is done without both its unit tests and its end-to-end test passing.

---

## 8. Definition of done

Before reporting a task complete:

1. Tests were written first, and all tests pass.
2. Every variable has an explicit type.
3. No duplicated widget or logic; shared code moved to `core/`.
4. Repo returns `StateResource`; errors routed through `network_error_handler`.
5. Mock repo added or updated, and swappable from `core/di`.
6. No stray strings, colors, endpoints, map keys, or route names outside their constants files.
7. Cubit and repo are disposed with their screen.
8. Builders/listeners wrap only the subtree that needs them.
9. No abstraction beyond what these instructions describe.
10. A subtask report was written to `configurations/reports/` (see §9).

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
