# Reports

One report per subtask, written when that subtask is finished.

**File name:** `<sprintNo>.<taskNo>.<subtaskNo>.md` — e.g. `2.1.3.md` for Sprint 2, Task 1,
Subtask 3.

Write in **simple English**. Someone who has not read the code should understand what happened.
Keep it short — four headings, a few lines each:

```markdown
# 2.1.3 — News mock repo

## What was asked
One or two plain sentences.

## What changed
- `lib/features/news_feed/business_logic/news_mock_repo.dart` — new, returns 10 fake articles.
- `lib/core/di/app_di.dart` — one line to swap the real repo for the mock.

## What was tested
- 6 unit tests: success returns 10 articles, failure returns an error message.
- `flutter analyze` clean, all 34 tests passing.

## Anything left open
"Nothing" is a valid answer.
```
