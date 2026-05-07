# Maglev Cycle 9: Physics and VRM Loading

## The Context

The gateway merges two input types at full rate after Cycle 9. This cycle loads the Maglev train scene with stationary cores on a banking train, verifies replication across clients, and confirms VRM avatar loading from the chunk store. Banking is a scene parameter change; VRM loading is verified in the same session as physics baseline.

Baked assets from Cycle 3 must be available in the chunk store before this cycle begins. Banking and VRM loading are combined here to reduce the number of cycles before the first physics demo.

## The Problem Statement

Physics replication to clients with different frame rates requires validation before dynamic forces are added. Adding banking motion and rolling cores at the same time as replication makes any failure unattributable. This cycle proves the replication layer works before the physics is made dynamic.

## Design

Load the Maglev train scene on the zone server. The train banks on a fixed schedule. Quantum Data-Cores sit stationary on the floor under authoritative physics (held by a constraint). The zone server sends datagram state each tick; both clients display the core and avatar positions.

The PCVR client sees the car as a waist-height diorama; the Steam Deck client sees the same instance as an isometric action-RPG. Both see their respective VRM avatars.

Pass criteria:

- [ ] Zone server loads the Maglev train scene from the chunk store
- [ ] Core positions agree between both clients each tick for 60 seconds under continuous banking
- [ ] Zone server tick rate holds at 20 Hz with physics active
- [ ] VRM avatars (PCVR and Steam Deck) load from the chunk store without error; humanoid skeleton root present
- [ ] No entity desync over the run

## Estimate

**10 days** (2026-06-02 → 2026-06-16). First cycle to load game assets and run physics. The zone server initial deploy took 2 days; adding a physics scene, banking animation, and VRM loading from the chunk store is the first substantial game dev work with no prior baseline. Projecting 2× the zone-console build time (6 working days) plus physics integration overhead.

## CRIS Score

| Factor          | Score | Evidence                                                                                                                             |
| --------------- | ----- | ------------------------------------------------------------------------------------------------------------------------------------ |
| **C**omplexity  | 6     | Physics replication to clients with different frame rates is untested, but a static scene removes the dynamic normal force variable. |
| **R**each       | 10    | Cycle 10 cannot begin until replication itself is verified.                                                                          |
| **I**mpediment  | 9     | A replication bug here means Cycle 10 results are unreliable.                                                                        |
| **S**takeholder | 10    | Gate for Cycle 10 and beyond.                                                                                                        |
| **Total**       | 8.75  | Build after Cycles 8 and 6 pass.                                                                                                     |

## The Downsides

A passing Cycle 9 does not validate rolling physics or causal ordering; those require Cycle 10.

## The Road Not Taken

Starting with rolling cores was rejected — replication and rolling-core physics are easier to separate when cores are stationary.

## Status

Status: Draft

## Decision Makers

- Lead Architect / Fabric Maintainer
- Game Director

## Tags

- maglev-cycle-9, physics-vrm, replication, galls-law, 20260506-maglev-cycle-9-physics-vrm, present-proposal-template

## Further Reading

```
@misc{v_sekai_2026,
  title = {V-Sekai},
  year  = {2026},
  url   = {https://v-sekai.org/}
}
```
