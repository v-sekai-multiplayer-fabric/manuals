---
title: r128 Q64.64 fixed-point as a Lean library for the cores
date: 2026-06-12
status: accepted
decision-makers: K. S. Ernest (iFire) Lee
---

## Context and Problem Statement

The deterministic cores ([the determinism decision](20260611-deterministic-cores-integer-seeded-rng.md)) need Q64.64 fixed-point math inside the Lean kernels, which lower to SPIR-V through [lean-slang](20260611-core-codegen-lean-slang.md). The engine already vendors the C `r128` library (`thirdparty/misc/r128`), but the kernels are authored in Lean.

## Considered Options

- Call the vendored C `r128` from the host only and keep the kernels in floating point.
- Reimplement Q64.64 ad hoc inside each kernel.
- Port `r128` to a Lean library the kernels import.

## Decision Outcome

Chosen option: provide `r128` as a Lean library that the cores import for their Q64.64 fixed-point math, because one Lean implementation feeds every kernel and lowers to SPIR-V over 64-bit integer pairs, while the vendored C `thirdparty/misc/r128` stays the host reference the Lean library matches. Keeping the kernels in floating point breaks determinism, and an ad-hoc Q64.64 per kernel drifts.

## Consequences

- The cores share one fixed-point implementation, so the host reference and the SPIR-V kernels agree bit-for-bit.
- The Lean library lowers through lean-slang, so the fixed-point ops reach SPIR-V over 64-bit integer pairs.
- A Plausible suite checks the Lean `r128` against the vendored C `r128` for matching results.

## Confirmation

The Lean `r128` library matches the vendored `thirdparty/misc/r128` on a Plausible cross-check, and the lowered SPIR-V reproduces the same results.
