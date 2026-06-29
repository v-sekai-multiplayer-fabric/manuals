---
title: Defer the loot-slice hardening scope until its need arrives
date: 2026-06-29
status: accepted
decision-makers: K. S. Ernest (iFire) Lee
---

# Defer the loot-slice hardening scope until its need arrives

## The Context

The [loot-action core-loop MVP vertical slice](20260611-loot-action-core-loop-mvp-vertical-slice.md) decides a large scope: five named cores, a CockroachDB adapter, a measured 90 Hz performance gate, and a SteamVR build. Its stated goal, though, is narrow — one slice "complete enough to exercise every integration seam." The running `godot-loop-slice` already carries that loop end to end (Hub to Field to Hub, through transport, server authority, loot contention, and SQLite-backed persistence), and the playable-loop smoke passes. The integration goal is met.

The rest of the decided scope is production hardening and platform reach. None of it adds integration coverage the running loop does not already have. Per [YAGNI times structure to the need](20260629-yagni-times-structure-to-need.md), structure waits for the feature that needs it: committing on a guess spends the option to build the right thing once the need is known, and the cost lands early while the return lands late.

## The Problem Statement

The decided-but-unbuilt items sit in the slice record as if they were live pending work. That conflates the shipped deliverable with deferred work and invites building structure ahead of demonstrated need. The slice record needs a companion that names each deferred item and the concrete trigger that revives it, so that nothing is silently dropped and nothing is built early.

## Design

Carry the unbuilt scope forward as deferred-until-needed, each item paired with the trigger that materializes its need. Build an item when its trigger fires, not before.

| Deferred item                                                                                                                                                                           | Why it waits                                                                                     | Trigger that revives it                                                                  |
| --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------ | ---------------------------------------------------------------------------------------- |
| Presence as a separate named reducer, today folded into the Hilbert interest core and multiplayer sink ([presence core](20260611-hexagon-presence-core.md))                             | Remote-pose interpolation runs in the slice; a separate reducer adds no integration coverage now | Remote-pose interpolation needs its own testable reducer, or avatar-fidelity work begins |
| Progression as a separate reducer, today an inline inventory append ([progression core](20260611-hexagon-progression-core.md))                                                          | The inventory delta commits correctly inline; a reducer is structure ahead of need               | Inventory or affinity logic outgrows append, or deterministic replay is required         |
| Budgeter core, unimplemented ([budgeter core](20260611-hexagon-budgeter-core.md))                                                                                                       | Nothing measures or breaches the frame floor yet                                                 | The frame floor is actually breached under load, or the performance gate is enforced     |
| CockroachDB adapter, with SQLite the only path today ([CockroachDB with mTLS](20260501-cockroachdb-with-mtls-role-separation.md))                                                       | Single-node SQLite carries the slice's persistence round trip                                    | Persistence needs multi-node storage or mTLS role separation beyond single-node SQLite   |
| Measured performance gate — 90 Hz, 500,000 triangles, 200 draw calls per eye ([first-party content and zone-baker budgets](20260611-first-party-curated-content-zone-baker-budgets.md)) | No headset target consumes the gate; placeholder content makes the number premature              | A real headset build is the sign-off step                                                |
| Real OpenXR build, where the desktop preset duplicates Windows Desktop with no XR options ([headless OpenXR testing with Monado](20260612-headless-openxr-testing-with-monado.md))      | The slice is verified headless; a real XR export is platform reach, not integration              | A headset playthrough is the acceptance step                                             |

The items the slice record already files after the gate — ranged and caster archetypes, Steam Frame and Steam Deck builds, in-headset authoring, [rollback](20260611-server-authoritative-simulation-deferred-rollback.md), and user-generated content — stay deferred where they are. This record cross-references them rather than restating them.

## The Downsides

- A timing judgment can defer something whose need turns out to be near. The named triggers are the early warning; the response is to build once the trigger fires.
- The slice's full picture now spans two records. The cross-links between this record and the slice record bind them.

## The Road Not Taken

- Build the full decided gate now — rejected as anti-YAGNI; most of it adds production hardening and platform reach, not integration coverage, and pays the optionality and timing bills for a need that has not arrived.
- Leave the unbuilt items in the slice record as "pending" — rejected; it conflates the shipped deliverable with deferred work and invites building ahead of need.

## Confirmation

The slice record's [Confirmation](20260611-loot-action-core-loop-mvp-vertical-slice.md) points here for the deferred scope. Each item above names the trigger that revives it. The decision holds while no trigger has fired; an item is revived by a new or updated decision record when its trigger arrives.
