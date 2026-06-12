---
title: One transport listener per authority pending http3 multi-session fixes
date: 2026-06-12
status: accepted
decision-makers: K. S. Ernest (iFire) Lee
---

## Context and Problem Statement

The four-player contention smoke (the `loot` repo, `adapters/godot`) drives one `WebTransportPeer.create_server` listener in the merged assembly (`0518217f44`) with four concurrent client sessions. Three behaviors surface: incoming datagrams from every session multiplex into the server's packet queue correctly; replies reach only one session regardless of `set_target_peer` / `get_packet_peer`; and a session teardown during traffic aborts the process with a double free (`quic_picoquic_backend.cpp`). A second `create_server` in the same process fails with "server already listening", so the backend holds one listener per process.

## Decision Outcome

Chosen option: until the module carries per-session peer routing and clean teardown, the loop runs one listener per authority process, attributes requesters in the message body rather than by transport peer id, and verifies the authority's resolutions at the harness against the Lean golden vectors. The grant-delivery path back to each client is blocked on the module fixes, which are queued as engine work: per-session ids on the MultiplayerPeer surface, teardown without the double free, and ideally multiple listeners per process.

## Consequences

- The four-player smoke is verifying authoritative resolution (64 rounds matching the Lean golden vectors from four concurrent clients) while grant delivery waits on the reply-routing fix.
- The loot and combat wire parities are unaffected, because a single session per listener works end to end.
- Issues stay disabled on the engine fork, so this record carries the findings.

## Confirmation

The four-player smoke passes at the harness, and a multi-session reply test starts passing per session when the module fix lands.

## More Information

The fix is open as [godot#56](https://github.com/v-sekai-multiplayer-fabric/godot/pull/56): a mutex-guarded session list with MultiplayerPeer ids replaces the single slot, ingress attributes its session, egress routes by target (broadcast at zero), the drain validates session membership, and teardown erases before delete. The pattern matches the single pending-slot bug fixed in `fire/webtransportd@f0fc9a4`. Post-fix, all four clients receive their own announcements and the server survives every teardown; the one-listener-per-process limit stands. A `FabricMultiplayerPeer` probe (ENet factories injected) also routes four clients correctly and stays an alternative transport for the loop.
