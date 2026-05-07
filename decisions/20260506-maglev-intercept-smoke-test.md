# Maglev Intercept: Cross-Platform Tilt-Shift Smoke Test

## The Context

The stack: `multiplayer-fabric-gateway` (Elixir, UDP 443 → zone UDP 7443, WebTransport/QUIC datagrams), `multiplayer-fabric-zone` (headless Godot `template_release double`), `multiplayer-fabric-uro` (Phoenix shard registry and asset API), single-node CockroachDB on Fly's 6PN private network.

Zone authority is geometric — `ZoneRange.contains(hilbert3D(pos))` determines ownership, gossip-learned, with uniqueness proven under `DisjointRanges`. Scores and persistent player state sit in a reserved logical partition of the 30-bit Hilbert space (the persona partition), governed by the same invariant as spatial zones. This is the first attempt to load all four layers together under cross-platform input.

## The Problem Statement

The full scenario — cross-platform clients, authoritative rolling-core physics, and a causal cross-zone score commit — is too complex to build and validate in one pass. A system assembled from untested parts at full complexity has no debuggable baseline.

## Design

Players start mid-breach on a moving Maglev Data-Courier train, fight drones, retrieve Quantum Data-Cores rolling across the banking floor, and slot them into the mainframe terminal within 3 minutes. The PCVR client sees the car as a waist-height diorama; the Steam Deck client sees the same instance as an isometric action-RPG.

Each layer is a separate cycle — a working system and a gate before the next begins.

| Cycle | C   | What it proves                                                                                       | Depends on | Document                                                      |
| ----- | --- | ---------------------------------------------------------------------------------------------------- | ---------- | ------------------------------------------------------------- |
| 0     | 8   | Terraform applies Fly.io resources; all apps, IPs, volumes, and secrets present                      | —          | [cycle-0](20260506-maglev-cycle-0-infra.md)                   |
| 1     | 6   | Gateway + zone handshake; one Godot datagram end-to-end                                              | 0          | [cycle-1](20260506-maglev-cycle-1-gateway-handshake.md)       |
| 2     | 7   | OTEL → VictoriaTraces/Metrics/Logs live (parallel)                                                   | 1          | [cycle-2](20260506-maglev-cycle-2-observability.md)           |
| 3     | 7   | Baker: train scene + VRM avatars via aria-storage → uro (parallel)                                   | 1          | [cycle-3](20260506-maglev-cycle-3-baker.md)                   |
| 4     | 8   | Direct uro → CockroachDB connection; mTLS, IPv6, prepare:unnamed (parallel)                          | 1          | [cycle-4](20260506-maglev-cycle-4-db-connection.md)           |
| 5     | 7   | Zone-console (ratatui TUI) connects and shows tick rate (parallel)                                   | 1          | [cycle-5](20260506-maglev-cycle-5-zone-console.md)            |
| 6     | 6   | 16 clients (14 taskweft bots + PCVR + Steam Deck); broadcast at MMOG load                            | 1, 2       | [cycle-6](20260506-maglev-cycle-6-mmog-load.md)               |
| 7     | 7   | IK routing and merge: format proven at 1 Hz, merge logic at 10 Hz                                    | 6          | [cycle-7](20260506-maglev-cycle-7-ik-routing.md)              |
| 8     | 6   | Full headset-rate IK merged without head-of-line blocking                                            | 7          | [cycle-8](20260506-maglev-cycle-8-ik-merge.md)                |
| 9     | 6   | Banking train + stationary cores replicate; VRM avatars load from chunk store                        | 8, 3       | [cycle-9](20260506-maglev-cycle-9-physics-vrm.md)             |
| 10    | 6   | Rolling cores under banking + causal ordering of core-slot events                                    | 9, 2, 5    | [cycle-10](20260506-maglev-cycle-10-dynamic-physics-score.md) |
| 11    | 6   | Full causal write: persona zone commits; uro persists score                                          | 10, 4      | [cycle-11](20260506-maglev-cycle-11-db-write.md)              |
| 12    | 3   | Game cycle planning: scoped ADRs and estimates for drone AI, combat, grab, slot, timer, camera modes | 9          | [cycle-12](20260506-maglev-cycle-12-game-planning.md)         |

Taskweft-confirmed ordering: 13 cycles (0–12) running in number order. Cycle 0 gates everything. Parallel tracks 2–5 all start after Cycle 1; Cycle 2 (observability) must complete before Cycle 6; Cycle 3 (baker) must complete before Cycle 9; Cycle 5 (zone-console) must complete before Cycle 10; bake jobs (1–3 h) always complete before the networking cycles (≥1 day each).

Cycle 7 combines 1 Hz routing and 10 Hz merge into one cycle; Cycle 8 adds full headset rate. If the team is confident in the merge after Cycle 7, Cycle 8 can be skipped.

`multiplayer-fabric-predictive-bvh` (interest management via predictive BVH) is exercised in Cycle 10: with 16 moving clients the BVH computes at least 2 distinct interest zones, verified in zone-console. Full cross-zone interest management (multiple zone servers) is left for a separate cycle series.

## CRIS Score

| Factor          | Score | Evidence                                                                                                                               |
| --------------- | ----- | -------------------------------------------------------------------------------------------------------------------------------------- |
| **C**omplexity  | 4     | Merging a 6-DOF IK stream with gamepad input in one physics tick, plus a cross-zone causal score commit, is untested in this codebase. |
| **R**each       | 10    | Every future gameplay module runs on the gateway, zone server, replication cycle, and persona zone these cycles exercise.              |
| **I**mpediment  | 9     | Physics desync or a broken persona write path blocks game design; either requires rewriting the netcode layer.                         |
| **S**takeholder | 10    | Primary proof-of-concept for the V-Sekai Fire multiplayer fabric.                                                                      |
| **Total**       | 8.25  | Build now.                                                                                                                             |

## The Downsides

Cycle 10 requires Cyberprep art assets and MToon shaders tuned for both targets before it can run. Physics replication will stress WebTransport bandwidth. If the persona zone goes down, that player's attributes are offline until it recovers. The shared-world UX for a standing VR player and a seated thumbstick player needs a separate design pass that cannot begin until Cycle 10 is stable.

Three gaps against industry par remain out of scope for this smoke test. Network condition simulation (artificial latency, jitter, packet loss) is standard in Unity Netcode, Photon, and Mirror but is not injected in these cycles. Reconnect storm testing — all 16 clients disconnecting and reconnecting simultaneously — is absent; VRChat's largest outage traced to this failure mode. Automated CI/CD execution is also absent; industry runs a 5-minute smoke gate on every deploy, whereas these cycles are human-run, week-scale exercises.

## The Road Not Taken

A steampunk skyship setting was rejected — it conflicts with the anime/VRM art targets and drifts toward fantasy MMO conventions.

Building the full scenario in one pass was the original plan, dropped when the staging approach proved easier to attribute failures.

## Status

Status: Draft

## Decision Makers

- Lead Architect / Fabric Maintainer
- Game Director

## Tags

- smoke-test, cross-platform, tilt-shift, cyberprep, in-medias-res, persona-zone, shared-nothing, galls-law, 20260506-maglev-intercept-smoke-test, present-proposal-template

## Further Reading

```
@misc{gall_1975,
  author = {Gall, John},
  title  = {Systemantics: How Systems Work and Especially How They Fail},
  year   = {1975}
}

@misc{v_sekai_2026,
  title = {V-Sekai},
  year  = {2026},
  url   = {https://v-sekai.org/}
}
```
