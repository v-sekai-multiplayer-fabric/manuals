---
title: Five-second transaction limit (bounded operations)
date: 2026-06-12
status: accepted
decision-makers: K. S. Ernest (iFire) Lee
---

## Context and Problem Statement

A connection that silently desyncs wastes a player's time: the loop bug had a client believe it was joined while the server had dropped it, and it waited forever. FoundationDB bounds every transaction to five seconds and aborts past that, so a stuck operation fails fast instead of hanging. The slice wants the same guarantee across the operations that can block — connection recovery, the runtime MCP round trips, and any commit.

## Decision Outcome

Chosen option: no operation waits longer than five seconds; past that it aborts or self-heals. The connection state machine re-joins a client that stops hearing the server, and recovery is bounded — a [Lean plus Plausible model](https://github.com/v-sekai-multiplayer-fabric/connection-fsm) proves the protocol sound (the client's belief never disagrees with the server once settled) and complete within a five-second budget (an awake client returns to a healthy joined state within five ticks, one tick per second). The buggy protocol without the re-join rule is shown not complete: Plausible finds a permanent ghost that stays unhealthy after a hundred seconds. The runtime MCP operator calls carry a five-second deadline, and a commit that exceeds the budget aborts rather than blocking the loop.

## Consequences

- A desynced client recovers inside five seconds rather than hanging, so a player never waits on a dead connection.
- The bound is a proof, not a hope: the model is the source of truth, and the loop client's connection logic matches it (the liveliness window is fifteen seconds, the re-join delay four, so recovery lands inside five).
- Operations that cannot finish in five seconds surface as failures the caller handles, which keeps the loop responsive.

## Confirmation

`lake exe fsm_demo` reports soundness and five-second recovery clean over a thirty-thousand-history sweep, with Plausible finding no counter-example for the fixed protocol and a ghost witness for the buggy one.
