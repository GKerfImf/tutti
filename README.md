# Tutti

A verified collaborative-text CRDT in [Lean 4](https://lean-lang.org/), served as a gRPC microservice.

> **This project is 100% vibecoded.** All code and proofs are written by AI agents (Claude Code). A human reviews and merges every pull request, but writes none of it. See [How this project is built](#how-this-project-is-built).

## What it's for

Tutti aims to:

1. **Verify a CRDT in Lean:** prove the properties collaborative editing relies on, checked by Lean's kernel.
2. **Ship it as a real service:** a sync server for collaborative documents, speaking gRPC. Clients submit and fetch operations and subscribe to updates.
3. **Connect the proofs to the running system:** the service's handlers are proved to refine the model, and checks at the boundaries (storage, network) fail stop instead of silently breaking the guarantees.
4. **Be useful beyond this repo:** serve as a verified reference for testing other CRDT implementations.

## Planned architecture

```
client ──gRPC/TLS──▶ sidecar (Rust, tonic) ──Unix socket──▶ Lean service
                                                             ├─ verified framing + protobuf codec
                                                             ├─ CRDT (proved)
                                                             └─ handlers (proved against the model;
                                                                runtime contract checks on storage)
```

The sidecar handles TLS, HTTP/2 and gRPC, which stay unverified and trusted. Everything behind it is in Lean.

## How this project is built

- AI agents write everything: Lean definitions, theorem statements, proofs, the Rust sidecar, CI.
- Each task arrives as a pull request. The maintainer reviews it and merges it; agents never merge their own work.
- The rules agents follow live in [`AGENTS.md`](AGENTS.md).

## Building

You need [elan](https://github.com/leanprover/elan), Lean's toolchain manager. It installs the pinned Lean version automatically.

```sh
lake build        # type-check and compile
lake exe tutti    # run the executable
```
