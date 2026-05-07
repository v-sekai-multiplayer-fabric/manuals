# Maglev Cycle 5: Zone-Console TUI Observer

## The Context

`multiplayer-fabric-zone-console` is a ratatui TUI that observes the zone over WebTransport. It is in the production stack and is the operator's primary visibility into zone health during and after mission cycles. Cycle 5 depends only on Cycle 1 (zone server live) and runs in parallel with the game-logic track.

## The Problem Statement

The zone-console has not connected to the zone server under the Fly deployment and confirmed it can display entity state and tick rate. Without a passing Cycle 5, operators have no real-time view into the zone during Cycles 9–10, where physics desync and causal ordering failures are the primary risks.

## Design

Start zone-console targeting the Fly zone server. Confirm the TUI displays: connected status, current tick rate (targeting 20 Hz), and at least one entity visible in the entity list.

Pass criteria:

- [ ] zone-console connects without error
- [ ] Tick rate displayed at 15 Hz or above (full 20 Hz target confirmed in Cycle 10)
- [ ] At least one entity visible in the TUI entity list
- [ ] Clean disconnect on exit with no orphaned connection

## Estimate

**2 days** (2026-05-09 → 2026-05-12, parallel). Zone-console was built from scratch in 6 working days (2026-04-21–28). The work here is connecting the existing TUI to the deployed Fly gateway rather than a local target — config and endpoint change only.

## CRIS Score

| Factor          | Score | Evidence                                                                                              |
| --------------- | ----- | ----------------------------------------------------------------------------------------------------- |
| **C**omplexity  | 7     | WebTransport observer is simpler than the game clients; the risk is ratatui rendering on headless CI. |
| **R**each       | 9     | Operators need this during Cycles 4–2 to confirm tick rate holds under dynamic physics load.          |
| **I**mpediment  | 7     | A missing observer does not block gameplay but leaves Cycles 4–2 without operator-facing monitoring.  |
| **S**takeholder | 10    | Operator visibility tool for the production stack.                                                    |
| **Total**       | 8.25  | Build after Cycle 1 passes, in parallel with Cycles 6–11.                                             |

## The Downsides

A passing Cycle 5 does not validate zone-console under load; the full 20 Hz tick rate and entity count targets are confirmed during Cycle 10.

## The Road Not Taken

Deferring to after Cycle 10 was rejected — the observer is needed during Cycle 10 to confirm tick rate holds at 20 Hz under dynamic physics load.

## Status

Status: Draft

## Decision Makers

- Lead Architect / Fabric Maintainer

## Tags

- maglev-cycle-5, zone-console, ratatui, observer, galls-law, 20260506-maglev-cycle-5-zone-console, present-proposal-template

## Further Reading

```
@techreport{20260506_cycle1,
  title       = {Maglev Cycle 1: Godot Client Gateway Handshake},
  institution = {V-Sekai Fire},
  year        = {2026},
  type        = {Architecture Decision Record},
  note        = {decisions/20260506-maglev-cycle-1-gateway-handshake.md}
}

@techreport{20260501_webtransport,
  title       = {Use WebTransport over QUIC for game traffic},
  institution = {V-Sekai Fire},
  year        = {2026},
  type        = {Architecture Decision Record},
  note        = {decisions/20260501-webtransport-over-quic-for-game-traffic.md}
}

@misc{v_sekai_2026,
  title = {V-Sekai},
  year  = {2026},
  url   = {https://v-sekai.org/}
}
```
