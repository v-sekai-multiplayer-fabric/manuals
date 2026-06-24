---
title: Combat hexagon — core, ports, and adapters
date: 2026-06-11
status: accepted
tier: proof of concept
decision-makers: K. S. Ernest (iFire) Lee
---

## Context and Problem Statement

The combat concern — combo timing, hit validation, the enemy spawn-invulnerability window, and damage — needs to be deterministic and testable with no server and no headset. Per [the hexagonal decision](20260610-hexagonal-core-ports-adapters.md) it becomes a core behind narrow ports.

## Decision Outcome

Chosen option: structure combat as a hexagon. The core resolves the combo timing, validates each hit against the authoritative positions, holds the enemy invulnerable for its spawn window, and deducts health, as a pure reducer ([the core contract](20260611-core-contract-pure-reducer-byte-state.md)) over deterministic state ([the determinism decision](20260611-deterministic-cores-integer-seeded-rng.md)).

Driving ports: `input_source` (player commands with timestamps and targets), `tick_source` (the constant-step clock), `behavior_source` (enemy intents). Driven ports: `state_sink` (authoritative entity state), `event_sink` (hits, deaths, door unlocks). Adapters: `feat/module-http3` feeds `input_source`; the `zone-server` hosts the core and drives `tick_source` under [server authority](20260611-server-authoritative-simulation-deferred-rollback.md); [sandboxed behavior](20260611-generated-behavior-sandboxed-riscv.md) implements `behavior_source`; a fixture adapter replays recorded inputs for CI.

## Consequences

- The server-authoritative adapter binds `input_source` and `state_sink` with interpolation and no prediction for the deadline; the rollback adapter lands after the gate behind the same ports.
- The combat core runs headless against fixtures, so a flaky adapter fails in isolation.
- The melee archetype ships first; the ranged and caster archetypes land after the gate.

## Confirmation

The combat core passes its fixtures, and a melee combo lands a hit under server authority on the OpenXR client.
