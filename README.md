# Tutti

A verified collaborative-text CRDT in [Lean 4](https://lean-lang.org/), served as a gRPC microservice.

> **This project is 100% vibecoded.** All code and proofs are written by AI agents (Claude Code). A human reviews and merges every pull request, but writes none of it. See [How this project is built](#how-this-project-is-built).

## Status

Early days. The repository contains a Lake project scaffold and nothing verified yet. Everything below is the plan, not a description of working code.

## What it's for

Collaborative editors such as Yjs, Automerge and Zed let several people edit the same text concurrently, often offline, and merge the results without a central lock. They rely on *sequence CRDTs*, data structures whose replicas converge to the same document whatever order edits arrive in.

Sequence CRDTs are notoriously subtle. Several published algorithms turned out to suffer from *interleaving anomalies*: two people type words at the same spot at the same time and get their characters mixed together. The **Fugue** algorithm ([Weidner & Kleppmann, "The Art of the Fugue"](https://arxiv.org/abs/2305.00583)) is designed to avoid this, and its paper proves *maximal non-interleaving*, on paper.

Tutti aims to:

1. **Mechanize Fugue in Lean:** prove convergence and non-interleaving, checked by Lean's kernel.
2. **Ship it as a real service:** a sync server for collaborative documents, speaking gRPC. Clients submit and fetch operations and subscribe to updates.
3. **Connect the proofs to the running system:** the service's handlers are proved to refine the model, and checks at the boundaries (storage, network) fail stop instead of silently breaking the guarantees.
4. **Test widely used libraries against it:** use the verified model as a reference to fuzz Yjs and Automerge for divergences.

## Planned architecture

```
client ──gRPC/TLS──▶ sidecar (Rust, tonic) ──Unix socket──▶ Lean service
                                                             ├─ verified framing + protobuf codec
                                                             ├─ Fugue CRDT (proved)
                                                             └─ handlers (proved against the model;
                                                                runtime contract checks on storage)
```

The sidecar handles TLS, HTTP/2 and gRPC, which stay unverified and trusted. Everything behind it is in Lean.

## What "verified" will mean here

Lean's kernel checks every proof, so a proof can't be wrong. A **theorem statement** can be: it might say something weaker than intended. In this project the statements are the part that deserves scrutiny, and every pull request lists the statements it adds or changes.

The trusted base will include the Lean compiler and runtime, the sidecar, the storage backend, and the operating system.

## How this project is built

- AI agents write everything: Lean definitions, theorem statements, proofs, the Rust sidecar, CI.
- Each task arrives as a pull request. The maintainer reviews it and merges it; agents never merge their own work.
- The rules agents follow live in [`CLAUDE.md`](CLAUDE.md).

Partly this is an experiment in how far AI can carry a formal-verification project when a human only reviews. Judge the code and proofs on their own merits; the kernel checks the proofs, and you can check the statements.

## Building

You need [elan](https://github.com/leanprover/elan), Lean's toolchain manager. It installs the pinned Lean version automatically.

```sh
lake build        # type-check and compile
lake exe tutti    # run the executable
```
