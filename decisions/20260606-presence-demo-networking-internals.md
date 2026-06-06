---
title: Presence demo networking internals
date: 2026-06-06
status: accepted
tier: baseline
---

## Context and Problem Statement

The [presence demo](20260606-multiplayer-presence-demo-orbs.md) vetoes Godot's
high-level networking and sends pose data with low-level explicit calls. This
records the engine pieces that make that work and how a head or hand pose reaches
the wire. The relevant code lives on the engine fork's feature branches, which the
[`merge`](https://github.com/v-sekai-multiplayer-fabric/merge) recipe assembles;
the engine is [pinned to a frozen Godot 4.7 commit](20260606-pin-engine-to-frozen-godot-4-7.md).

## Decision Drivers

- High-rate pose streams must be compact, so the wire format has to be tight.
- Reuse the engine's own WebTransport stack rather than a side channel.
- Avoid the per-property bookkeeping of automatic scene replication.

## Considered Options

- High-level scene replication (`MultiplayerSynchronizer` / `MultiplayerSpawner`).
- Explicit RPC over a standard `MultiplayerPeer` (ENet / WebRTC / WebSocket).
- Explicit messages over the engine's WebTransport (HTTP/3) module.

## Decision Outcome

Chosen option: "Explicit messages over the engine's WebTransport module", with
poses encoded as compact binary. High-level replication stays off.

### Transport: the HTTP/3 / WebTransport module

On the `feat/module-http3` branch, `modules/http3` provides the WebTransport stack:

- `modules/http3/quic_picoquic_backend.{cpp,h}` — native QUIC via picoquic.
- `modules/http3/quic_web_backend.cpp` + `quic_web_glue.js` — the web/wasm backend.
- `modules/http3/http3_client.{cpp,h}`, `quic_client.{cpp,h}`, `quic_server.h`.
- Exposed classes (`modules/http3/doc_classes/`): `HTTP3Client`, `QUICClient`,
  `QUICServer`, `WebTransportPeer`.
- Demos: `modules/http3/demo/wt_client_test.gd`, `wt_server_demo.gd`,
  `wt_browser_test.html`.
- `lean/http3/PollingTermination.lean` carries a Lean proof about the polling loop.

WebTransport gives reliable streams and unreliable datagrams over one QUIC
connection, so high-rate pose updates ride datagrams.

### Pose source

Poses come from the XR trackers (`servers/xr/`):

- `XRPositionalTracker` (`servers/xr/xr_positional_tracker.h`) holds named
  `XRPose` entries with a hand enum.
- `XRPose` (`servers/xr/xr_pose.h`) carries a `Transform3D`, linear and angular
  velocity, and a tracking-confidence level.
- `XRHandTracker` (`servers/xr/xr_hand_tracker.h`) tracks 26 hand joints, each a
  `Transform3D`.

The demo reads the local head and hand poses, encodes them, and sends them; remote
peers apply the decoded transforms to orb nodes.

### What is vetoed and why

`modules/multiplayer` ships the high-level nodes (`MultiplayerSynchronizer`,
`MultiplayerSpawner`, `SceneReplicationInterface`) and the Variant-based RPC path
(`MultiplayerAPI::encode_and_compress_variants`). Variant encoding of a
`Transform3D` is general but fat, so it is not used for the pose stream. The demo
hand-rolls a compact binary encoding instead. Standard `MultiplayerPeer`
transports (`modules/enet`, `modules/webrtc`, `modules/websocket`) exist, but the
stack's transport is WebTransport.

### Identity (stretch)

The pen, `modules/cassie` on `feat/module-cassie`, supplies the optional
[signing identity](20260606-feature-classification-poc-baseline-stretch.md).

### Consequences

- Good: poses ride compact datagrams over the same WebTransport the gateway uses.
- Good: the engine already proves the transport with the `http3` demos and a Lean
  termination proof.
- Bad: the compact encoding, send rate, and interpolation are hand-written and
  have to be maintained.
- Bad: the WebTransport, cassie, and fabric modules live on separate feature
  branches, so the full stack only exists in the assembled engine.

### Confirmation

The `modules/http3` demos open a WebTransport client and server. The presence demo
sends head and hand poses as datagrams and a remote peer renders the orbs from the
decoded transforms.

## More Information

Modules cited here are on the engine fork's feature branches (`feat/module-http3`,
`feat/module-cassie`) and are composed by the `merge` `gitassembly` recipe onto the
frozen Godot 4.7 base.
