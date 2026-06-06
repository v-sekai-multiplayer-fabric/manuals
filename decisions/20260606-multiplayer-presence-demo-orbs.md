---
title: Minimal multiplayer presence demo with head and hand orbs
date: 2026-06-06
status: proposed
decision-makers: K. S. Ernest Lee, lyuma
---

## Context and Problem Statement

The `xr-grid` debug scene currently shows one skinned-mesh hero asset (a rigged
mesh with a skeleton, not a VRM) standing on the grid as a visual landmark; it
does not represent a player. Around it float a few clusters of small colored orbs.
Each cluster encodes the translation and orientation (a full pose) of one tracked
point — head, hand, hand — for a remote participant, drawn as orientation and translation orbs. The next
increment should prove shared presence: several people in the same space at once,
at the scale of a full V-Sekai Discord call. What is the smallest piece that
demonstrates real multiplayer presence without committing to
full networked avatars for everyone?

![The `xr-grid` debug scene, 2026-06-06: a skinned-mesh hero asset as a visual landmark, with each remote participant drawn as head and hand orientation-and-translation orb clusters. [@vsekai_xrgrid_debug_2026]](attachments/20260606_vsekai-mpf_xr-grid-debug-orbs_0001.png)

## Decision Drivers

- Smallest demonstrable multiplayer increment on top of the existing scene.
- Real presence for many participants, roughly a Discord call's worth.
- Cheap per-player representation that still reads as a person.
- Identity should be optional, not a login wall.

## Considered Options

- Full networked character (skinned mesh) for every participant.
- Head plus two hand orbs per participant (3-point tracking representation).
- Text nameplates with no embodiment.

## Decision Outcome

Chosen option: "Head plus two hand orbs per participant", because three tracked
points per person convey presence and gesture at a fraction of the cost of a full
avatar, which lets the demo scale to a whole call.

Scope of the demo:

- Every participant, including the local player, is represented by three tracked
  points — head, hand, hand — each shown as a cluster of orbs that encodes its
  translation and orientation (pose). The existing skinned-mesh hero asset stays
  in the scene as a visual landmark and does not represent any player.
- The room scales to a V-Sekai Discord call's worth of participants.
- A participant who wants to identify themselves signs with the pen
  ([cassie](20260606-feature-classification-poc-baseline-stretch.md)); the
  signature is the identity mark. Unsigned participants stay anonymous orbs.
- Built on [xr-grid](https://github.com/v-sekai-multiplayer-fabric/xr-grid).

### Networking

Godot's high-level networking is vetoed for this demo. Automatic scene
replication (the `MultiplayerSpawner` and `MultiplayerSynchronizer` nodes and the
`SceneMultiplayer` replicator) is not used. Orb poses go over low-level, explicit
RPC calls instead, so the demo controls exactly what is sent each tick and how it
is encoded. See the [networking technical details](20260606-presence-demo-networking-internals.md).

### Consequences

- Good: presence and gesture for many people at low per-player cost.
- Good: identity is opt-in through signing, so there is no login step.
- Bad: orbs are not full avatars, so the demo does not exercise avatar networking
  or IK.
- Neutral: pen signing depends on cassie, whose pen stroke creation is solid, so
  signing (which only needs strokes) is reliable. Only cassie's patch surface
  creation is buggy (loses about 90%), and signing does not depend on that.
- Neutral: explicit RPC means hand-rolling the encoding, send rate, and
  interpolation. That cost is the point. Pose streams have to be fast and
  succinct, so they need a compact binary wire format. If it could be easy it
  would be JSON, and JSON is too fat for high-rate pose updates.

### Confirmation

A session shows multiple participants, each rendered as three orb clusters (head,
hand, hand) tracking the pose of those points, at call scale. Signing with the pen
produces a visible identifying mark next to that participant's orbs.

## More Information

This is the "smallest new piece" milestone: expand the existing `xr-grid` debug
scene (a skinned-mesh hero asset as a landmark, plus orientation and translation orb clusters)
into a populated room. It composes the [pen-stroke / cassie capability](20260606-feature-classification-poc-baseline-stretch.md)
for optional identity.
