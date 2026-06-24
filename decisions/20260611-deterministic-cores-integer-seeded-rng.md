---
title: Deterministic cores via r128 fixed-point and seeded RNG
date: 2026-06-11
status: accepted
decision-makers: K. S. Ernest (iFire) Lee
---

## Context and Problem Statement

Replay, recorded fixtures, and the future rollback adapter need the authoritative cores to be bit-exact across the RTX 4090 workstation and the Steam Deck. IEEE-754 floating point diverges across platforms through fused multiply-add, instruction reordering, and transcendental functions, so a float in the authoritative path breaks replay silently.

## Decision Outcome

Chosen option: the authoritative cores use r128 Q64.64 fixed-point and a seeded RNG threaded through state, with no floating point, because fixed-point over 64-bit integers reproduces bit-exact across machines while an explicit seed in the state makes the loot roll replayable. The cores import r128 as a Lean library ([the r128 Lean library decision](20260612-r128-fixed-point-as-lean-library.md)) that lowers to SPIR-V, and the engine's vendored `thirdparty/misc/r128` stays the host reference.

## Consequences

- Replay and snapshots stay byte-exact, so the rollback adapter becomes cheap.
- The fixtures pin exact outputs, so a divergence shows up as a failing fixture rather than a silent drift.
- The loot roll is reproducible from the seed in the state.

## Confirmation

Replaying an input log reproduces the state hash on every target.
