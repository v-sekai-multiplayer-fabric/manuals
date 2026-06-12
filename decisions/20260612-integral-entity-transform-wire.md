---
title: Integral entity-transform wire (int64 micrometers, no origin shift)
date: 2026-06-12
status: accepted
decision-makers: K. S. Ernest (iFire) Lee
---

## Context and Problem Statement

The fabric replicates entity transforms in a fixed 100-byte packet (`XRGridEntityPacket`). The determinism doctrine keeps the authoritative state in integers and r128 fixed point, yet the packet carried position as `f64` — three doubles whose 52-bit mantissa cannot even represent a Q64.64 value. Floating point on the wire reintroduces the cross-platform divergence the determinism decision rules out.

## Decision Outcome

Chosen option: every field on the wire is integral. Position becomes **int64 absolute micrometers** — the integer twin of the `precision=double` large-world coordinate, so there is no camera-relative origin shifting (the double-precision build and r128 exist precisely to hold absolute coordinates). Velocity stays i16, scaled to `PBVH_V_MAX_PHYSICAL_DEFAULT` so it shares the predictive BVH's units. Rotation stays i16 swing-twist. A 42-byte userdata payload carries control and state. The packet keeps its 100 bytes.

Position int64 micrometers spans plus or minus 9.2e12 m at 1 um, and matches the [lean-predictive-bvh](https://github.com/v-sekai-multiplayer-fabric/lean-predictive-bvh) int64-um AABB space. The authoritative position stays r128; the wire is its micrometer-scale integer projection. Clients render rather than re-simulate ([server authority](20260611-server-authoritative-simulation-deferred-rollback.md)), so micrometer quantization is below perception while the exact state remains server-side.

A Lean 4 plus Plausible model in [entity_packet](https://github.com/v-sekai-multiplayer-fabric/entity_packet) is the source of truth: a roundtrip property and a size invariant the C++ must match, plus a golden-vector differential.

## Consequences

- The wire has no floating point; replication is deterministic across platforms.
- The packet speaks the predictive BVH's native int64-micrometer language, so position flows into the BVH with no conversion.
- Tying velocity to `PBVH_V_MAX_PHYSICAL_DEFAULT` closes a latent drift (the codec had an ad-hoc times-1000 scale that the BVH-sync review surfaced).
- Density, when it matters, comes from value delta-from-baseline rather than origin rebasing; entropy coding stays off the per-tick path because variable length breaks the fixed datagram layout.

## Confirmation

The entity_packet Plausible suite passes a 50000-vector roundtrip and size sweep, and the engine's C++ decode matches the Lean golden bytes on 64 vectors. The change lands on `feat/module-xr-grid` and `feat/module-multiplayer-fabric`.
