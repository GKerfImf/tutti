def hello := "world"

theorem add0n : ∀ (m : Nat), 0 + m = m := by
  intro n
  induction n with
  | zero => rfl
  | succ k ih => sorry

theorem add_comm : ∀ (n m : Nat), n + m = m + n := by
  intro n
  induction n with
  | zero => apply add0n
  | succ k ih => sorry
