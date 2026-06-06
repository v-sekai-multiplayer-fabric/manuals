---
title: Minimal multiplayer presence demo with head and hand orbs
date: 2026-06-06
status: superseded by 20260606-presence-marker-representation.md
tier: proof of concept
decision-makers: K. S. Ernest Lee, lyuma
---

## Context and Problem Statement

The `xr-grid` debug scene shows one skinned-mesh hero asset (a rigged mesh with a
skeleton, not a VRM) on the grid as a visual landmark; it does not represent a
player. Around it float clusters of small colored orbs, each encoding the pose
(translation and orientation) of one tracked point — head, hand, hand — for a
remote participant. What is the smallest piece that proves shared presence at the
scale of a full V-Sekai Discord call?

![The `xr-grid` debug scene, 2026-06-06: a skinned-mesh hero asset as a visual landmark, with each remote participant drawn as head and hand orientation-and-translation orb clusters. [@vsekai_xrgrid_debug_2026]](attachments/20260606_vsekai-mpf_xr-grid-debug-orbs_0001.png)

## Decision Drivers

- Smallest demonstrable multiplayer increment on top of the existing scene.
- Real presence for a Discord call's worth of participants.
- Cheap per-player representation that still reads as a person.
- Identity should be optional, not a login wall.

## Considered Options

- Full networked character (skinned mesh) for every participant.
- Head plus two hand orbs per participant (3-point tracking).
- Text nameplates with no embodiment.

## Decision Outcome

Chosen option: "Head plus two hand orbs per participant", because three tracked
points convey presence and gesture cheaply enough to scale to a whole call.

- Every participant, including the local player, is three orb clusters (head,
  hand, hand), each encoding a pose. The hero asset stays as a landmark only.
- The room scales to a Discord call's worth of participants.
- Identity is opt-in: a participant signs with the
  [cassie](20260606-feature-classification-poc-baseline-stretch.md) pen; unsigned
  ones stay anonymous orbs.
- Poses go over low-level
  [WebTransport datagrams](20260606-presence-demo-networking-internals.md), not
  high-level replication.
- Built on [xr-grid](https://github.com/v-sekai-multiplayer-fabric/xr-grid).

### Consequences

- Good: presence and gesture for many people at low per-player cost.
- Good: identity is opt-in, so there is no login step.
- Bad: orbs are not full avatars, so avatar networking and IK go unexercised.
- Neutral: signing rides cassie's pen stroke creation, which is solid; only its
  patch surface creation is buggy, and signing does not use that.

### Confirmation

A session shows multiple participants as head and hand orb clusters tracking their
poses at call scale, and signing produces a visible mark by that participant.
