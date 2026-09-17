# Project structure and engineering rules

The full document lives at the repository root as [`CLAUDE.md`](../../CLAUDE.md), so that every AI
assistant loads it automatically. It is the single source of truth — edit it there, not here.

It covers:

1. Project structure
2. Layer responsibilities (`core/apis`, `core/di`, `core/networking`, `core/routing`,
   `core/utils`, `core/shared_widgets`, `features/<feature>`)
3. Architecture rules (cubit-only, concrete repos, `StateResource`, disposal, builder scoping)
4. Coding rules (explicit types, DRY, no over-engineering, no hardcoded values)
5. Theme (red + accents, white fonts)
6. Mock repos
7. Testing — TDD
8. Definition of done
9. `configurations/` — documentation and reports
10. Working rhythm — one subtask at a time, tests first, report after
