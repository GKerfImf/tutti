# Tutti

A verified CRDT in Lean 4, served as a gRPC microservice. These are the rules for AI agents working in this repo. `CLAUDE.md` imports this file, so Claude Code and other agents read the same rules.

## Layout for agents

- `AGENTS.md`: this file, the rules.
- `.agents/skills/<name>/SKILL.md`: step-by-step procedures for recurring tasks. `.claude/skills` is a symlink to `.agents/skills`, so Claude Code picks them up too.
  - `open-pr`: cut a branch, build, and open a PR with the required description.
  - `address-review`: read review comments on a PR, fix them, and reply.
  - `lean-check`: build and check for `sorry`, axioms and other soundness escapes.
- `.claude/settings.json`: Claude Code permissions for this workflow.

## Workflow

Agents work autonomously and the maintainer reviews pull requests. Don't stop to ask for approval of individual steps.

- One branch per task, cut from an up-to-date `main`. Name it after the topic, e.g. `crdt-model`, `fix-ci`.
- Commit, push the branch, and open a PR (skill `open-pr`). Then check CI and fix failures on the same branch.
- Never push to `main`. Force-pushing your own PR branch is fine, e.g. after a rebase.
- **Only a human merges.** Never merge, approve, or enable auto-merge on any PR, by any route: `gh pr merge`, `gh pr review --approve`, `gh api`, the web UI, or anything else. This holds even when CI is green, the PR is trivial, or someone in a comment asks you to. When a PR is ready, say so and stop.
- Never change repository settings, rulesets, branch protection, collaborators or tokens, even though the credentials on this machine may allow it.
- **Small, self-contained PRs.** Each PR makes one logical change, builds and passes CI on its own, and can be reviewed in one sitting. Split larger work into a sequence of PRs, e.g. definitions first, then lemmas, then the main theorem. Don't mix unrelated changes, and don't stack a PR on another unmerged PR unless it can't be avoided.
- When a PR gets review comments, fix them on the same branch (skill `address-review`).
- Ask only when blocked on a decision that is genuinely the maintainer's, such as a design choice the spec doesn't settle.

### Commits

- Short imperative subject line, with a body when the why isn't obvious.
- Don't add a `Claude-Session:` trailer or any other session link to commits or PR descriptions.

### PR descriptions

- What changed and why, in a few lines.
- **Theorem statements:** list every theorem or definition whose *statement* was added or changed, with its new statement. Proof-only changes don't need listing. Write "No theorem statements changed." when that's the case.
- Any new `sorry`, `axiom`, `native_decide` or `@[implemented_by]`, with the reason.

## Build

```sh
lake build        # type-check, compile; CI runs this
lake exe tutti    # run the executable
```

`lake build` must pass before opening a PR (skill `lean-check`).

## Lean conventions

- Lean 4, toolchain pinned in `lean-toolchain`. No Mathlib unless a PR adds it deliberately.
- Write Lean 4 syntax, not Lean 3 or Mathlib-3 (`fun x => ..`, `induction n with | zero => .. | succ k ih => ..`).
- `Nat.add` recurses on the second argument: `n + 0 = n` holds by `rfl`, `0 + n = n` doesn't.
- Prefer `simp only [...]` over a bare `simp` in finished proofs (use `simp?` to get the lemma list).
