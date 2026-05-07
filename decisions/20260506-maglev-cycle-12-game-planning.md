# Maglev Cycle 12: Game Cycle Planning

## The Context

Cycles 0–5 prove the networking, physics, and persistence layers. Cycle 9 is the first cycle to run a real physics scene with assets; by the time it passes, the team has actual frame budget data from zone-console, a working grab-ready physics scene, and the interaction system (`xr_controller_interaction_helper.gd`) half-integrated. That is the earliest point at which game cycle estimates are reliable.

## The Problem Statement

Six game systems remain unbuilt for the vertical slice and have no prior baseline in this codebase. Estimating them before Cycle 9 passes produces numbers with no evidence. Cycle 12 produces scoped ADRs and estimates for each remaining system using the Cycle 9 scene as a measured baseline.

## Design

Run Cycle 12 immediately after Cycle 9 passes. For each of the six systems below, produce one ADR following the present-proposal-template with a pass criteria checklist, CRIS score, and estimate derived from Cycle 9 frame budget and zone-console tick data.

| System                           | Depends on                         | Notes                                                                                     |
| -------------------------------- | ---------------------------------- | ----------------------------------------------------------------------------------------- |
| Drone AI                         | Cycle 9 scene                      | Pathfinding and attack behaviour in the zone server; no prior AI baseline                 |
| Combat / health                  | Cycle 9 scene                      | Damage model, respawn, HUD; no prior baseline                                             |
| Core grab mechanic               | Cycle 9 scene + interaction system | `xr_controller_interaction_helper.gd` is solved; needs wiring to rolling cores            |
| Slot-into-terminal interaction   | Core grab                          | Win condition trigger; same interaction system path                                       |
| 3-minute timer and win/lose flow | Slot interaction                   | Game loop state machine; triggers Cycle 11 DB write                                       |
| Camera modes                     | Cycle 9 scene                      | PCVR tilt-shift diorama rig; Steam Deck isometric rig; same instance, different viewports |

Art asset production (train geometry, drone models, terminal, Quantum Data-Core models, VRM avatars with MToon shaders) is a parallel track owned by the art team. Cycle 12 produces the art brief and schedule alongside the engineering ADRs; it does not estimate or gate on art completion.

Pass criteria:

- [ ] One ADR per system above, with pass criteria checklist and CRIS score
- [ ] Each ADR includes a working-days estimate with a stated basis in Cycle 9 measurements
- [ ] Art brief delivered to art team with asset list, MToon shader targets, and poly/texture budgets for both PCVR diorama and Steam Deck isometric viewports
- [ ] Updated project timeline incorporating all six game cycles into the Maglev Intercept sequence

## Estimate

**3 days** (2026-06-16 → 2026-06-19). Planning cycle only; no code. Requires Cycle 9 zone-console tick data and frame budget before it can begin.

## CRIS Score

| Factor          | Score | Evidence                                                                                                                            |
| --------------- | ----- | ----------------------------------------------------------------------------------------------------------------------------------- |
| **C**omplexity  | 3     | Writing ADRs and estimates is low effort; the inputs (Cycle 9 measurements, interaction system design) are well understood by then. |
| **R**reach      | 10    | All six remaining game systems are unscoped until this cycle completes.                                                             |
| **I**mpediment  | 8     | Starting game dev without scoped ADRs risks scope creep and unattributable failures in a system with no prior game-logic baseline.  |
| **S**takeholder | 10    | Game Director and art team both block on this cycle for production planning.                                                        |
| **Total**       | 7.75  | Build immediately after Cycle 9 passes.                                                                                             |

## The Downsides

Cycle 12 produces plans, not working software. A week of slippage in Cycle 9 delays the planning cycle by the same amount.

## The Road Not Taken

Planning the game cycles now (before Cycle 9) was considered and rejected — estimates made without a running physics scene and real frame budget data have no evidence base.

## Status

Status: Draft

## Decision Makers

- Lead Architect / Fabric Maintainer
- Game Director

## Tags

- maglev-cycle-12, game-planning, vertical-slice, galls-law, 20260506-maglev-cycle-12-game-planning, present-proposal-template

## Further Reading

```
@misc{v_sekai_2026,
  title = {V-Sekai},
  year  = {2026},
  url   = {https://v-sekai.org/}
}
```
