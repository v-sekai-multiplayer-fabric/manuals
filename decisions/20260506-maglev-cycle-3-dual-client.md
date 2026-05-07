# Maglev Cycle 3: Dual Same-Type Clients

## The Context

With one Godot client verified end-to-end and the observability stack live (Cycle 2), the next question is whether the gateway can multiplex two same-type connections into one zone server tick while keeping both clients synchronized. Observability must be running before this cycle begins — a broadcast failure here is unattributable without gateway traces.

## The Problem Statement

16 clients in one zone is the minimum to qualify as MMOG load. 14 are taskweft bots (~15 MB each, not full Godot processes); 1 is the PCVR human; 1 is the Steam Deck human. Connection-slot handling, datagram ordering, and state broadcast to 16 sockets have not been tested under concurrent load.

## Design

16 clients connect to the gateway simultaneously. All receive datagram state from the same zone server instance each tick. One static entity in an empty world.

Pass criteria:
- [ ] All 16 clients receive consistent entity state each tick for 60 seconds
- [ ] No client observes a tick gap or duplicate
- [ ] Zone-console shows 16 entities at 20 Hz
- [ ] Gateway process memory stays flat under 16 connections
- [ ] All 14 bots disconnect and reconnect simultaneously; gateway recovers within 5 seconds and all clients resync without a restart
- [ ] Under 100 ms injected latency and 2% packet loss, no client desyncs over 30 seconds

## CRIS Score

| Factor          | Score | Evidence |
| --------------- | ----- | -------- |
| **C**omplexity  | 6     | 16 same-type connections; taskweft bots are proven infrastructure but have not been combined with the gateway at this count. |
| **R**each       | 10    | All subsequent cycles run at 16-client load. |
| **I**mpediment  | 9     | A desync at 16 clients means the gateway's broadcast path is broken before heterogeneous input is added. |
| **S**takeholder | 10    | Gate for Cycles 4–8. |
| **Total**       | 8.75  | Build after Cycles 1 and 2 pass. |

## The Downsides

16 same-type bots leave the heterogeneous input path unvalidated.

## The Road Not Taken

Starting immediately with heterogeneous IK and gamepad inputs at 16-client scale was rejected — a broadcast failure at full complexity would be ambiguous between gateway capacity and input-mux issues. Cycle 3 uses uniform bots to isolate the broadcast path.

## Status

Status: Draft

## Decision Makers

- Lead Architect / Fabric Maintainer

## Tags

- maglev-cycle-3, dual-client, gateway, smoke-test, galls-law, 20260506-maglev-cycle-3-dual-client, present-proposal-template

## Further Reading

```
@misc{v_sekai_2026,
  title = {V-Sekai},
  year  = {2026},
  url   = {https://v-sekai.org/}
}
```
