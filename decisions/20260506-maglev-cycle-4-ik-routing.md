# Maglev Cycle 4: IK Routing and Merge

## The Context

Two same-type Godot clients share a zone after Cycle 3. Cycle 4 swaps one Steam Deck client for a PCVR client and confirms that a single 6-DOF IK datagram travels through the gateway and reaches the zone server. The rate and merge logic are not yet in scope.

## The Problem Statement

A PCVR client's IK datagram format differs structurally from a gamepad datagram. The gateway has never parsed one. Before testing merge behaviour at full IK rate, the routing path itself must be shown to work for at least one IK datagram.

## Design

The PCVR client — running the solved `multiplayer-fabric-interaction-system` addon via `xr_controller_interaction_helper.gd` and `xr_action_host.gd` — starts at 1 Hz IK and ramps to 10 Hz. The Steam Deck client sends gamepad datagrams at normal cadence. The gateway routes and merges both streams to the zone server on UDP 7443. The world is static.

The 1 Hz phase confirms the IK datagram format parses correctly. The 10 Hz phase confirms the gateway's merge logic is correct under concurrent input before full rate is introduced.

Pass criteria:
- [ ] Zone server receives and logs at least one IK datagram without parse error at 1 Hz
- [ ] Zone server receives a merged tick containing both input types at 10 Hz
- [ ] No gamepad datagram dropped over 60 seconds at 10 Hz
- [ ] No gateway crash or restart

## CRIS Score

| Factor          | Score | Evidence |
| --------------- | ----- | -------- |
| **C**omplexity  | 7     | IK datagram format is new to the gateway but the routing path is identical to gamepad; one datagram per second removes rate risk. |
| **R**each       | 10    | Cycle 5 (full-rate IK) cannot begin without a proven merge baseline. |
| **I**mpediment  | 9     | A parse failure here blocks all cross-platform work. |
| **S**takeholder | 10    | Gate for Cycle 5 and all subsequent cross-platform cycles. |
| **Total**       | 9.0   | Build after Cycle 3 passes. |

## The Downsides

10 Hz IK does not trigger head-of-line pressure; that stress test is Cycle 5 at full headset rate.

## The Road Not Taken

Going straight to full headset rate was rejected — a routing bug and a head-of-line bug at the same time are harder to separate than routing at 1 Hz and merge at 10 Hz in one cycle.

## Status

Status: Draft

## Decision Makers

- Lead Architect / Fabric Maintainer

## Tags

- maglev-cycle-4, ik-routing-merge, heterogeneous-input, galls-law, 20260506-maglev-cycle-4-ik-routing-merge, present-proposal-template

## Further Reading

```
@misc{v_sekai_2026,
  title = {V-Sekai},
  year  = {2026},
  url   = {https://v-sekai.org/}
}
```
