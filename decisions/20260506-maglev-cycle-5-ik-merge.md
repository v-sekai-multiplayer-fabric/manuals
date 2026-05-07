# Maglev Cycle 5: Full-Rate IK Merge

## The Context

Cycle 4 confirms routing and merge at 10 Hz. Cycle 5 raises the PCVR client to operating rate — continuous 6-DOF IK at headset cadence — alongside full-rate gamepad input, and verifies the gateway merges both without head-of-line blocking.

## The Problem Statement

6-DOF IK datagrams arrive an order of magnitude more frequently than gamepad events. The gateway's merge path must handle that rate differential without blocking lower-frequency gamepad events. A head-of-line stall on the IK queue would delay or drop gamepad events silently.

## Design

The PCVR client sends 6-DOF IK datagrams at full headset rate. The Steam Deck client sends gamepad datagrams at normal cadence. Both arrive on UDP 443. The gateway merges them per tick and forwards to the zone server on UDP 7443. The world is static.

Pass criteria:
- [ ] Zone server processes ticks containing both input types without stalls or skipped events
- [ ] No gamepad datagram is silently dropped over 60 seconds under full IK load
- [ ] Gateway CPU stays within budget under both streams at full rate

## CRIS Score

| Factor          | Score | Evidence |
| --------------- | ----- | -------- |
| **C**omplexity  | 6     | Merging a continuous high-frequency IK stream with low-frequency gamepad input without head-of-line effects is untested in this codebase. |
| **R**each       | 10    | Cross-platform play at operating rate requires this path; Cycles 7 and beyond add physics and persistence on top of it. |
| **I**mpediment  | 9     | A head-of-line bug here makes physics results in Cycle 7 and beyond unreliable for the gamepad client. |
| **S**takeholder | 10    | Gate for cross-platform physics and score. |
| **Total**       | 8.25  | Build after Cycle 4 passes. |

## The Downsides

The Meta XR Simulator on macOS covers the initial run, but Cycle 5 must be re-run on physical hardware before Cycle 7 begins — the simulator does not reproduce real headset IK datagram rates under motion.

## The Road Not Taken

Skipping Cycles 4 and 5 together was rejected — a failure at full rate conflates routing bugs with rate bugs, leaving both unattributable.

## Status

Status: Draft

## Decision Makers

- Lead Architect / Fabric Maintainer

## Tags

- maglev-cycle-5, ik-merge, heterogeneous-input, galls-law, 20260506-maglev-cycle-5-ik-merge, present-proposal-template

## Further Reading

```
@misc{v_sekai_2026,
  title = {V-Sekai},
  year  = {2026},
  url   = {https://v-sekai.org/}
}
```
