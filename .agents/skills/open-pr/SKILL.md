---
name: open-pr
description: Cut a branch, build, commit, push and open a pull request in the Tutti repo with the required description (theorem statements, soundness escapes). Use whenever a task is ready to go up for review.
---

# Open a PR

1. Start from an up-to-date `main`:
   ```sh
   git fetch origin
   git switch -c <topic> origin/main
   ```
   One branch per task. Keep the change small and self-contained (see `AGENTS.md`).
2. Make the change, then run the `lean-check` skill. Don't open a PR on a failing build.
3. Commit with a short imperative subject line. Add the attribution trailers your harness asks for.
4. Push: `git push -u origin <topic>`.
5. Open the PR against `main`:
   ```sh
   gh pr create --base main --title "<subject>" --body "<description>"
   ```
   The description must contain:
   - **What and why**, in a few lines.
   - **Theorem statements:** every theorem or definition whose statement was added, changed or removed, with the new statement. Or "No theorem statements changed."
   - **Soundness escapes:** any new `sorry`, `axiom`, `native_decide` or `@[implemented_by]`, with the reason. Omit this section if there are none.
6. Wait for CI with `gh pr checks <number> --watch`. If it fails, read the log (`gh run view <run-id> --log-failed`), fix it on the same branch, and push again.
7. Report the PR link and stop. **Never merge or approve it**; only the maintainer does.
