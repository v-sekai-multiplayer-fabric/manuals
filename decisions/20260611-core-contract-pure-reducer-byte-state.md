---
title: Cores as pure reducers over byte-serialized state
date: 2026-06-11
status: accepted
decision-makers: K. S. Ernest (iFire) Lee
---

## Context and Problem Statement

Every hexagonal core ([the hexagonal decision](20260610-hexagonal-core-ports-adapters.md)) needs to be replayable, snapshot-able, fixture-testable, and transport-agnostic. A core that hides mutable state behind methods defeats all four.

## Considered Options

- Stateful objects whose internal state lives behind methods.
- A pure reducer over an explicit, serializable state value.

## Decision Outcome

Chosen option: model each core as a pure reducer, `step : State -> Event -> State x Effects`, with `State`, `Event`, and `Effects` serialized to bytes deterministically, so the core is bytes to bytes. The flat C ABI exposes `step` plus `snapshot` and `restore` over the byte state, and the compute kernels lower through [lean-slang](20260611-core-codegen-lean-slang.md) to SPIR-V, dispatched on the GPU. Hidden mutable state defeats snapshots and exact fixtures, so the first option loses replay and rollback.

With [the determinism decision](20260611-deterministic-cores-integer-seeded-rng.md), this makes replay byte-exact and snapshots a value copy.

## Consequences

- Snapshots and rollback are copies of the state bytes.
- Fixtures pin exact output bytes, so a divergence shows up as a failing fixture.
- The same `step` backs every adapter, so `webtransportd` and the engine carry the same bytes.

## Confirmation

Replaying an event log reproduces the state bytes on every target.
