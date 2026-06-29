---
title: Presence demo pose networking
date: 2026-06-06
status: superseded by 20260611-loot-action-core-loop-mvp-vertical-slice.md
decision-makers: K. S. Ernest (iFire) Lee
tier: baseline
---

## Context and Problem Statement

The presence demo sends head and hand
poses to peers over the [WebTransport transport](20260606-webtransport-http3-transport.md).
How are those poses sourced, encoded, and sent?

## Decision Drivers

- High-rate pose streams must be compact.
- Reuse the engine's XR trackers and WebTransport datagrams.
- Avoid the per-property bookkeeping of automatic scene replication.

## Considered Options

- High-level scene replication (`MultiplayerSynchronizer` / `MultiplayerSpawner`).
- Explicit RPC with Variant-encoded arguments.
- Hand-rolled compact binary over WebTransport datagrams.

## Decision Outcome

Chosen option: "Hand-rolled compact binary over WebTransport datagrams".

- Pose source: `XRPositionalTracker` / `XRHandTracker` / `XRPose` (`servers/xr/`)
  give a `Transform3D`, velocity, and tracking confidence; a hand has 26 joints.
- Encoding: a compact binary layout, not `MultiplayerAPI`'s Variant encoding,
  which is too fat for high-rate poses.
- Vetoed: the high-level nodes in `modules/multiplayer`
  (`MultiplayerSynchronizer`, `MultiplayerSpawner`, `SceneReplicationInterface`).
- Identity: the [cassie](20260606-feature-classification-poc-baseline-stretch.md)
  pen supplies optional signing (stretch).

### Consequences

- Good: poses ride compact datagrams on the same WebTransport the gateway uses.
- Bad: the encoding, send rate, and interpolation are hand-written and maintained.

### Confirmation

The demo reads local head and hand poses, sends them as datagrams, and a remote
peer renders orbs from the decoded transforms.
