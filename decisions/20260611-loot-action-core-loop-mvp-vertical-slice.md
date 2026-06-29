---
title: Loot-action core-loop MVP vertical slice
date: 2026-06-11
status: accepted
decision-makers: K. S. Ernest (iFire) Lee
---

# Loot-action core-loop MVP vertical slice

## The Context

The fabric has transport, authority, persistence, and budget decisions in place, but no running loop that exercises all of them together. The team needs a first playable to find the gaps that only appear when the whole stack runs end to end: a social hub where players gather, an instanced combat zone where they fight and collect, and the round trip that carries the result back. Without a bounded target the risk is that each layer is individually correct but the integration is never tested until it is too late to fix.

## The Problem Statement

There is no single bounded deliverable that tells the team whether the stack works together. The team needs one vertical slice, small enough to build in a week, complete enough to exercise every integration seam: transport, server authority, loot contention, inventory persistence, performance budgeting, and the Hub-to-Field-to-Hub round trip.

## Design

Ship one vertical slice of an instanced, four-player loot-action core loop.

**Scene layout**

- One Hub deck with a shop backed by the loot and progression cores. The shop degrades to a free starting kit if the economy slips.
- One Field room: four players, one melee combo against one enemy, one loot drop, one persistence round trip.

**Loop**

1. Players gather in the Hub and form a party.
2. The party teleports into the Field instance hosted by `zone-server`.
3. One player lands a timed melee combo. The server validates the hit, deducts enemy health, and spawns a loot drop.
4. One player touches the drop first. The loot core resolves contention by receipt timestamp, grants the winner, and rejects the rest.
5. The progression core commits the inventory delta through the CockroachDB adapter (or the SQLite fallback if the commit path slips).
6. The party teleports back to the Hub. The shop reflects the new inventory.

**Cores**

Each concern is a hexagonal pure reducer ([the hexagonal decision](20260610-hexagonal-core-ports-adapters.md), [the core contract](20260611-core-contract-pure-reducer-byte-state.md)):

| Core                                                           | Responsibility                                           | Key ports                                                                     |
| -------------------------------------------------------------- | -------------------------------------------------------- | ----------------------------------------------------------------------------- |
| Combat ([decision](20260611-hexagon-combat-core.md))           | Combo timing, hit validation, health, enemy spawn window | `input_source`, `tick_source`, `behavior_source` → `state_sink`, `event_sink` |
| Loot ([decision](20260611-hexagon-loot-core.md))               | Drop generation, first-touch contention                  | `loot_request_source` → `grant_sink`, `inventory_delta_sink`                  |
| Presence ([decision](20260611-hexagon-presence-core.md))       | Remote-pose interpolation                                | `pose_source` → `avatar_sink`                                                 |
| Progression ([decision](20260611-hexagon-progression-core.md)) | Profile, inventory, affinity gate                        | `profile_source` → `commit_sink`                                              |
| Budgeter ([decision](20260611-hexagon-budgeter-core.md))       | Per-frame quality knobs under load                       | `measurement_source` → `knob_sink`                                            |

**Authority and networking**

The `zone-server` is the single authority per instance ([server-authoritative decision](20260611-server-authoritative-simulation-deferred-rollback.md)). For the deadline the model is server-authoritative with client interpolation and no prediction. The rollback adapter lands after the gate behind the same ports.

**Content and performance gate**

Content is first-party curated only; the `zone-baker` enforces hard budgets at bake time ([content decision](20260611-first-party-curated-content-zone-baker-budgets.md)). The sign-off gate is a SteamVR build at 90 Hz: four avatars and one Field room under 500,000 visible triangles and 200 draw calls per eye.

**What ships after the gate**

Ranged and caster archetypes, Steam Frame and Steam Deck builds, in-headset authoring, rollback, and user-generated content.

## The Downsides

- The slice runs on placeholder content; art is not gated, only the frame floor.
- Only the melee archetype ships; ranged and caster are explicitly deferred.
- No client prediction at the deadline; the rollback adapter lands after the gate.
- The SQLite fallback in progression degrades the inventory persistence, which is not visible to the player but makes the economy untrustworthy until the CockroachDB path is confirmed.

## The Road Not Taken

- Full toolchain and content pipeline first: building the pipeline before the loop pushes the integration gaps late, when they are most expensive. Rejected for the thin steel thread.
- Multi-archetype slice: ranged and caster widen scope beyond one week. Melee alone proves combat authority and loot contention; the others follow the gate.
- Broader platform launch: SteamVR is sufficient scope for the slice; Steam Frame and Steam Deck follow.
- Per-zone distributed authority (Maglev intercept model): a geometric Hilbert-zone authority was attempted and rejected in the Maglev smoke test. One `zone-server` per instance is simpler and sufficient for a four-player room.

## Confirmation

The slice's stated goal — exercise every integration seam — is met. On 2026-06-29 the playable-loop smoke (`smoke.sh`) runs end to end on the frozen Godot 4.7 double editor and passes: one authoritative server and four bot clients carry the Hub-to-Field-to-Hub round trip through transport, server authority, loot contention, and SQLite-backed inventory persistence. The run grants exactly one bot and commits exactly one profile row; the smoke asserts both — exactly one grant and exactly one committed row — and exits zero.

The integration is proven. The decided scope that is not built is production hardening and platform reach, which adds no integration coverage. As built on 2026-06-29, verified by reading the `godot-loop-slice` source:

- Two of the five cores exist as named pure resolvers wired into the server: combat (`core/combat.gd`) and loot (`core/loot.gd`). Presence runs through a Hilbert interest core (`core/hilbert.gd`) and a multiplayer sink (`adapters/multiplayer_sink.gd`) rather than a named presence core. Progression is an inline inventory append committed through a SQLite adapter (`adapters/sqlite_profiles.gd`) rather than a separate reducer. The budgeter core is not implemented.
- Persistence is SQLite. The CockroachDB adapter is not implemented.
- The performance gate (90 Hz, 500,000 triangles, 200 draw calls per eye) is not measured or enforced in the repository.
- The `OpenXR` desktop export preset duplicates the Windows Desktop preset and carries no XR options; the Quest Android preset is the configured XR target.

These decided-but-unbuilt items — the three cores as separate reducers, the CockroachDB adapter, the performance gate, and a real OpenXR build — carry forward as deferred-until-needed in [defer the loot-slice hardening scope until its need arrives](20260629-defer-loot-slice-hardening-until-needed.md).
