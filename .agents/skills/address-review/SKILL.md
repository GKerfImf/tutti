---
name: address-review
description: Read the maintainer's review comments on a Tutti pull request, fix each one on the PR's branch, push, and reply to every comment. Use when asked to check, fix or address PR comments or review feedback.
---

# Address review comments

1. Collect the feedback. Inline comments don't show up in `gh pr view`, so fetch them from the API:
   ```sh
   gh pr view <n> --json reviews,comments
   gh api repos/GKerfImf/tutti/pulls/<n>/comments \
     --jq '.[] | {id, path, start_line, line, body, in_reply_to_id}'
   ```
   A comment covers lines `start_line` to `line` of the file at the commit it was made on (`start_line` is null for single-line comments). Read those exact lines before acting. "Remove" on a range means the whole range.
2. Switch to the PR's branch and pull: `git switch <branch> && git pull`.
3. Fix every comment. Do what it asks, not more. If a comment is ambiguous, pick the most likely reading and say which one you picked in your reply.
4. Run the `lean-check` skill, commit ("Address review comments"), and push. Rebasing and force-pushing your own PR branch is fine.
5. If the fixes change what the PR does, update its description with `gh pr edit <n> --body ...`. That includes the theorem-statement list.
6. Reply to each comment with a one-line note on what changed:
   ```sh
   gh api repos/GKerfImf/tutti/pulls/<n>/comments/<id>/replies -f body="Done: ..."
   ```
7. Report what you changed and stop. **Never resolve the conversations, approve, or merge**; the maintainer does that.
