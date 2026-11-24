# Design: the CRDT model and what we prove

## 1. Choice of algorithm: Fugue, then FugueMax

We formalize **Fugue** and **FugueMax**, from Weidner & Kleppmann, ["The Art of the Fugue: Minimizing Interleaving in Collaborative Text Editing"](https://arxiv.org/abs/2305.00583) (IEEE TPDS 2025; section and theorem numbers below refer to arXiv v3).

Why these two:

- **The guarantee is strong and formal.** The paper defines *maximal non-interleaving* (Def. 4) and proves that FugueMax satisfies it (Thm. 9). It also proves that any algorithm satisfying it orders elements exactly as FugueMax does (Thm. 10). The proofs are on paper, so mechanizing them is new.
- **The alternatives are weaker.** According to the paper's Table I, RGA has backward interleaving, and Yjs (YATA) has multi-replica backward interleaving. Their main guarantee, forward non-interleaving, is one of the properties we prove for Fugue anyway.
- **The structure suits Lean.** The state is a tree, and the list is an in-order traversal of it. Most proofs are inductions on trees and lists.

The two algorithms differ only in how right-side siblings are ordered, so we stage it: **Fugue first** (simpler ordering; convergence and forward non-interleaving), **then FugueMax** (maximal non-interleaving). Everything built for Fugue carries over.

## 2. The model

### Elements and IDs

- An **ID** is `(replica, counter)`: the inserting replica's identifier and its per-replica counter. IDs are unique, and they are ordered lexicographically.
- Values have a generic type `α`. Text is `α := Char`.

### The tree

Every element ever inserted is a **node**:

```
node = (id, value : Option α, parent : NodeRef, side : L | R)
```

- `parent` is either the virtual **root** or another node. `side` says whether the node is a left or a right child of its parent.
- `value = none` is a **tombstone**: a deleted element. Tombstones are never removed, because they can be parents of other nodes.
- A node can have many left children and many right children. Children on the same side of the same parent are **siblings**.

### From tree to list

The list is the **in-order traversal** of the tree. For each node: first its left children, then the node itself (skipped if it's a tombstone), then its right children.

Siblings are traversed in order:
- **Fugue:** ascending ID, on both sides.
- **FugueMax:** left siblings as in Fugue. A right child also stores its **right origin**, and right siblings are ordered by the *reverse* list order of their right origins, with ties broken by ID (Def. 6).

### Operations

- **`insert i x`**, at replica `r`:
  - The **left origin** is the visible element at index `i − 1`, or the root if `i = 0`.
  - The **right origin** is the next node after the left origin in the traversal *including tombstones*, or "end" if there is none.
  - If the left origin has **no right children**, the new node becomes a **right child of the left origin**. Otherwise it becomes a **left child of the right origin** (Alg. 1, lines 25–28).
- **`delete i`:** set the value of the visible element at index `i` to `none`.

Operations are delivered by **causal broadcast**: a replica applies an operation only after everything that operation depends on.

### Representation in Lean (proposal)

- **Abstract state:** a finite set of nodes, plus well-formedness. That means unique IDs, every parent is either the root or a node in the set, and there's no cycle. The causal history guarantees acyclicity, so we keep the nodes in delivery order, with each parent appearing before its children. That also gives structural recursion for the traversal.
- **Replica state:** the incremental structure from the paper (each node with sorted lists of left and right children), plus a counter. This is what the service actually runs.
- **The link between them:** the replica's `values` equals the traversal of the abstract node set. Most of the real proof work is in this lemma.

## 3. What we prove

Each statement below becomes a Lean theorem. The phrasing here is informal; the exact Lean statements arrive in their own PRs and are listed in those PRs' descriptions.

**T1, convergence.** Two replicas that have applied the same set of operations, in any causal order, have the same list.

*Why it holds:* the replica's list is a function of the *set* of nodes (§2, the link lemma). The work is proving that the incremental, order-dependent updates compute that function.

**T2, strong list specification** (Attiya et al.; the paper's Thm. 1). There is a single total order `≺` on all elements ever inserted, such that:
- (a) every replica's list is its visible elements, sorted by `≺`;
- (b) every inserted element lands between the two neighbours it was inserted between, as the inserting replica saw them.

T2 implies T1. Part (b) is what makes T2 stronger than convergence: it rules out "converges, but to the wrong place".

**T3, forward non-interleaving** (Def. 2), for Fugue and FugueMax. If `A` is the left origin of `B`, and `B` comes before every other element whose left origin is `A`, then `A` and `B` are adjacent in the list.

Intuitively, when you type a word, nobody else's concurrent text ends up inside it. A useful step on the way is Lemma 7: forward non-interleaving holds *iff* the list order is a depth-first pre-order traversal of the left-origin tree.

**T4, maximal non-interleaving** (Def. 4, Thm. 9), for FugueMax. T3, plus:
- **backward non-interleaving:** if `B` is the right origin of `A`, and `A` comes after every other element whose right origin is `B`, then `A` and `B` are adjacent. The one exception is Lemma 5's case, where some interleaving can't be avoided.
- **tie-breaking:** elements with the same left origin and the same right origin are ordered by ID.

**Stretch goal, T5, uniqueness** (Thm. 10). Any list algorithm satisfying T2 and T4 orders elements exactly as FugueMax does. Stating it requires quantifying over list algorithms, so it needs a general notion of "list algorithm" first. It's out of scope until T1–T4 are done.

### Out of scope here

The service layer: wire format, gRPC, storage, and the refinement from handlers to this model. It gets its own design doc once the model exists.

## 4. Order of work

Each item is one or a few small PRs.

1. IDs, nodes, well-formed abstract states, and the traversal.
2. Fugue `insert` and `delete` on the abstract state, and the link lemma for the incremental replica state.
3. T1 and T2 for Fugue.
4. Left-origin trees, Lemma 7, and T3 for Fugue.
5. FugueMax: right origins, the new sibling order, and T1–T3 again (mostly reusing step 4).
6. T4.

## 5. Decisions

Settled with the maintainer:

1. **Use Mathlib.** It's added before step 1, for finite sets and its order and `List` lemmas. The cost is a heavy dependency and slower CI.
2. **Fugue first, then FugueMax.** The extra step is cheap and gives an early milestone.
3. **Generic element type `α`**, not `Char` only. It costs nothing in the proofs.
