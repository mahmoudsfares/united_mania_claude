# Features description

One markdown file per feature, named after the feature directory in `lib/features/`
(e.g. `home.md` describes `lib/features/home/`).

Each file states:

- **Purpose** — what the feature does for the user.
- **Screens** — the screens it owns and their route names.
- **Endpoints** — the `api_endpoints` constants it calls, and the request/response shape.
- **States** — the `StateResource` states the cubit emits and what the UI shows for each.
- **Models** — the models in `models/` and where their data comes from.

Create the file when the feature is added; update it whenever the feature's behaviour changes.

## Current contents

- [`news_feed.md`](news_feed.md) — the home screen: the NewsAPI contract, the `Article` model, the
  four screen states, and the free plan's limits.
- [`news_details.md`](news_details.md) — the article screen: what it shows, and the browser link.
- [`work_breakdown.md`](work_breakdown.md) — the build order: 4 sprints, 19 subtasks, each one
  independently implementable and testable. **Start here.**
