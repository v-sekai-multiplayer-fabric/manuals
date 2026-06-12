---
title: Fabric channels as reliability classes, control in payload
date: 2026-06-12
status: accepted
decision-makers: K. S. Ernest (iFire) Lee
---

## Context and Problem Statement

Transforms want unreliable, latest-wins delivery at tick rate; sparse control events (a teleport vote, a loot grab) want reliable, exactly-once delivery. Mixing both on one ordered stream lets a reliable event head-of-line-block the transform flow, and a separate text channel for control means two codecs and two reliability models to reason about.

## Decision Outcome

Chosen option: the fabric's logical channels are the reliability classes, and the 100-byte entity packet carries everything. `FabricMultiplayerPeer` runs one ENet host per channel, so channels are head-of-line-free: CH_INTEREST (1) carries unreliable transforms, CH_MIGRATION (0) carries reliable-ordered control and state. The lane is chosen with `set_transfer_channel` plus `set_transfer_mode`; a `cmd`/`action` byte in the payload picks the meaning within a lane.

Control rides the same packet as the transform that produced it, so an action arrives bound to its position and HLC — the server validates a hit against the exact transform and tick, atomically. The transport gives exactly-once per channel, so there is no sequence counter, repeat, or dedupe. Server-to-client state (phase, grant, reject) uses the same format under reserved global ids (a zone entity for phase, the player entity for grants).

## Consequences

- A reliable control event never stalls the unreliable transform stream, because each is a separate ENet host.
- One codec and one wire format both directions; text disappears entirely.
- A display name is a byte field in the payload, and bytes are integers, so even names stay integral and deterministic.

## Confirmation

The multi-session http3 fix ([godot#56](https://github.com/v-sekai-multiplayer-fabric/godot/pull/56)) routes per-session replies, and a `FabricMultiplayerPeer` probe routes four concurrent clients with the ENet factories injected.
