---
title: Server-authoritative simulation with deferred rollback
date: 2026-06-11
status: accepted
decision-makers: K. S. Ernest (iFire) Lee
---

## Context and Problem Statement

The loop needs one authority over combat state and loot contention. An earlier geometric Hilbert-zone authority attempt (the Maglev intercept smoke test) was rejected, and the one-week slice needs a simpler model that still resists client tampering.

## Decision Outcome

Chosen option: the headless `zone-server` owns entity transforms, health, combat state, and loot contention, and clients reconcile to the server snapshot, because a single authority per instance keeps the slice simple and tamper-resistant.

For the deadline the model is server-authoritative with client interpolation and no client prediction. The rollback adapter lands after the gate behind the same `input_source` and `state_sink`, so the swap never touches a core ([the combat hexagon](20260611-hexagon-combat-core.md), [the core contract](20260611-core-contract-pure-reducer-byte-state.md)).

## Consequences

- One authority per instance, so a per-connection transport child relays to that single core rather than holding state.
- Rollback is an adapter swap after the gate, not a rewrite.
- The deadline trades input snappiness for a far smaller build.

## Confirmation

A divergent client reconciles to the server snapshot, and combat and loot resolve identically across the four clients.
