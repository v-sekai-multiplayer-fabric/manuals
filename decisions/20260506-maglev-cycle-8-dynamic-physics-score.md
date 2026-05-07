# Maglev Cycle 8: Dynamic Physics and Causal Ordering

## The Context

With replication and banking proven in Cycle 7, Cycle 8 releases the cores to roll and runs the full mission. Causal ordering (VClock.le gating on core-slot events) is verified in the same run since mission events are its natural trigger.

Cycle 2 (observability) must be live before this cycle runs — a desync or ordering failure here without traces is undiagnosable.

## The Problem Statement

This codebase must validate rolling physics under a dynamic normal force combined with cross-zone causal ordering of core-slot events. The cores change trajectory continuously as the train banks; any tick-rate mismatch between the zone server and either client can diverge positions.

## Design

Confirm VictoriaTraces receives spans from the zone server before the 3-minute run begins. Core-slot events and their VClock timestamps appear in the trace output.

Load the Maglev train scene. The train banks on a fixed schedule. Quantum Data-Cores roll across the floor under authoritative physics. The zone server sends datagram state each tick; all clients display the result. Players fight drones and slot cores into the mainframe terminal over 3 minutes.

The PCVR client sees the car as a waist-height diorama; the Steam Deck client sees the same instance as an isometric action-RPG.

Pass criteria:
- [ ] No entity desync between any of the 16 clients over the 3-minute window
- [ ] Core positions agree within one physics tick across all clients at mission end
- [ ] Zone server tick rate holds at 20 Hz under banking motion, drone AI, and 16-client load
- [ ] Every core-slot `QueueOp` reaches the persona zone; VClock values advance monotonically
- [ ] No QueueOp accepted out of causal order
- [ ] `multiplayer-fabric-predictive-bvh` computes at least 2 distinct interest zones across the 16 clients; zone-console confirms all 16 entities visible

The Cyberprep environment with MToon shaders tuned for both targets is the first art cost in the cycle sequence and cannot begin until Cycle 5 is stable.

## CRIS Score

| Factor          | Score | Evidence |
| --------------- | ----- | -------- |
| **C**omplexity  | 6     | Rolling physics under a dynamic normal force, combined with cross-zone causal ordering of core-slot events, is untested in this codebase. |
| **R**each       | 10    | All gameplay built on this stack requires authoritative physics replication under dynamic load. |
| **I**mpediment  | 9     | Physics desync here blocks game design; fixing it likely requires changes to the replication layer, not just parameters. |
| **S**takeholder | 10    | Required for the full Maglev mission scenario. |
| **Total**       | 8.25  | Build after Cycles 7 and 2 pass. |

## The Downsides

A physics or ordering failure here could be replication, tick rate, dynamic normal force, or VClock gating; Cycles 1–7 narrow but do not eliminate that ambiguity.

## The Road Not Taken

Separating causal ordering into its own cycle was rejected — mission events are the natural trigger for core-slot QueueOps, so the two are co-occurring and cheaper to verify together.

## Status

Status: Draft

## Decision Makers

- Lead Architect / Fabric Maintainer
- Game Director

## Tags

- maglev-cycle-8, dynamic-physics, causal-ordering, replication, galls-law, 20260506-maglev-cycle-8-dynamic-physics-score, present-proposal-template

## Further Reading

```
@misc{v_sekai_2026,
  title = {V-Sekai},
  year  = {2026},
  url   = {https://v-sekai.org/}
}
```
