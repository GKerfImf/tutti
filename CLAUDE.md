# Tutti

A verified sequence CRDT (Fugue, Weidner & Kleppmann 2023) in Lean 4, served as a gRPC microservice.

## Agent workflow

Agents work autonomously and the maintainer reviews pull requests. Don't stop to ask for approval of individual steps.

- One branch per task, cut from an up-to-date `main`. Name it `<topic>`, e.g. `fugue-model`, `fix-ci`.
- Commit, push the branch, and open a PR with `gh pr create`. Then check CI (`gh pr checks`) and fix failures on the same branch.
- Never push to `main`, force-push, or merge a PR. Merging is the maintainer's call.
- Keep PRs focused: one logical change each.
- Ask only when blocked on a decision that is genuinely the maintainer's, such as a design choice the spec doesn't settle.

### PR descriptions

- What changed and why, in a few lines.
- **Theorem statements:** list every theorem or definition whose *statement* was added or changed, with its new statement. Proof-only changes don't need listing. Write "No theorem statements changed." when that's the case.
- Any new `sorry`, `axiom`, `native_decide` or `@[implemented_by]`, with the reason.

## Build

```sh
lake build        # type-check, compile; CI runs this
lake exe tutti    # run the executable
```

`lake build` must pass before opening a PR.

## Lean conventions

- Lean 4, toolchain pinned in `lean-toolchain`. No Mathlib unless a PR adds it deliberately.
- Write Lean 4 syntax, not Lean 3 or Mathlib-3 (`fun x => ..`, `induction n with | zero => .. | succ k ih => ..`).
- `Nat.add` recurses on the second argument: `n + 0 = n` holds by `rfl`, `0 + n = n` doesn't.
- Prefer `simp only [...]` over a bare `simp` in finished proofs (use `simp?` to get the lemma list).
