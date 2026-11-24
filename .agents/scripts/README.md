# Agent scripts

Use these for routine repo work instead of writing git and `gh` commands by hand. If one is missing or wrong, fix the script in a PR rather than working around it.

| Script | What it does |
|---|---|
| `new-branch <name>` | Start a task branch from an up-to-date `origin/main`. Refuses to run with a dirty working tree. |
| `check` | `lake build`, plus the soundness escapes (`sorry`, `axiom`, `native_decide`, `implemented_by`, `extern`) this branch adds. Fails if the build fails. |
| `push [--force]` | Push the current branch and set upstream. Never pushes `main`. `--force` uses `--force-with-lease`. |
| `open-pr <title> <body-file>` | Open a PR into `main` and print its URL. |
| `pr-body <n> [file]` | Print PR `n`'s description, or replace it with the file's contents. |
| `pr-comments <n> [--all]` | Review bodies, top-level comments, and inline threads with file and line range. Hides handled threads unless `--all`. |
| `reply <n> <comment-id> <text>` | Reply to an inline comment thread. Start with `Done:` once it's handled. |
| `wait-ci <n>` | Wait for CI. On failure, print the failing log lines. |
| `pr-status` | Every open PR, with its CI state and number of unhandled threads. |

Run them from anywhere in the repo, e.g. `.agents/scripts/check`.

Conventions:
- **PR bodies always go through a file** (`open-pr`, `pr-body`), never inline shell strings. Both scripts reject `` \` `` (an escaped backtick), the usual sign of a quoting mistake.
- **A thread counts as handled** when its last message is a reply starting with `Done`. Agents post with the maintainer's account, so authorship can't mark it.
- None of these scripts merges, approves or changes repository settings, and none will be added that does.
