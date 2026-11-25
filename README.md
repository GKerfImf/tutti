# Tutti

A verified collaborative-text CRDT in [Lean 4](https://lean-lang.org/), served as a gRPC microservice.

> **This project is 100% vibecoded.** All code and proofs are written by AI agents (Claude Code). A human reviews and merges every pull request, but writes none of it.

## What it's for

Tutti aims to:

1. **Verify a CRDT in Lean:** prove the properties collaborative editing relies on, checked by Lean's kernel.
2. **Ship it as a real service:** a sync server for collaborative documents, speaking gRPC. Clients submit and fetch operations and subscribe to updates.
3. **Connect the proofs to the running system:** the service's handlers are proved to refine the model, and checks at the boundaries (storage, network) fail stop instead of silently breaking the guarantees.
4. **Be useful beyond this repo:** serve as a verified reference for testing other CRDT implementations.
