---
name: lean-check
description: Build the Tutti Lean project and check it for soundness escapes (sorry, axioms, native_decide, implemented_by) before committing or opening a PR. Use after any change to Lean files.
---

# Check the Lean build

1. Build: `lake build`. It must finish with "Build completed successfully". Treat errors as blocking. Read warnings too, since `declaration uses 'sorry'` shows up only as a warning.
2. Look for soundness escapes added by your change:
   ```sh
   git diff origin/main -- '*.lean' | grep -nE '^\+.*\b(sorry|axiom|native_decide|implemented_by|extern)\b'
   ```
   Each hit must either go, or be listed with its reason in the PR description.
3. For any theorem you added or changed, check which axioms it depends on. Put this in a scratch file or at the end of the module, but don't commit it:
   ```lean
   #print axioms MyTheorem
   ```
   Only `propext`, `Classical.choice` and `Quot.sound` are acceptable. `sorryAx` means a `sorry` is hiding somewhere in the dependencies. `Lean.ofReduceBool` comes from `native_decide`.
4. If the build passes and every escape is accounted for, the change is ready to commit.
