---
title: Minimal multiplayer presence demo with head and hand orbs
date: 2026-06-06
status: proposed
decision-makers: K. S. Ernest Lee, lyuma
---

## Context and Problem Statement

The `xr-grid` debug scene currently shows one VRM avatar standing on the grid with
a few clusters of small colored orbs floating nearby as placeholder remote
players. The next increment should prove shared presence: several people in the
same space at once, at the scale of a full V-Sekai Discord call. What is the
smallest piece that demonstrates real multiplayer presence without committing to
full networked avatars for everyone?

## Decision Drivers

- Smallest demonstrable multiplayer increment on top of the existing scene.
- Real presence for many participants, roughly a Discord call's worth.
- Cheap per-player representation that still reads as a person.
- Identity should be optional, not a login wall.

## Considered Options

- Full networked VRM avatar for every participant.
- Head plus two hand orbs per participant (3-point tracking representation).
- Text nameplates with no embodiment.

## Decision Outcome

Chosen option: "Head plus two hand orbs per participant", because three tracked
points per person convey presence and gesture at a fraction of the cost of a full
avatar, which lets the demo scale to a whole call.

Scope of the demo:

- Each participant is represented by one head orb and two hand orbs, driven by
  their 3-point tracking. One full VRM (as in the current scene) can stand in for
  the local player.
- The room scales to a V-Sekai Discord call's worth of participants.
- A participant who wants to identify themselves signs with the pen
  ([cassie](20260606-feature-classification-poc-baseline-stretch.md)); the
  signature is the identity mark. Unsigned participants stay anonymous orbs.
- Built on [xr-grid](https://github.com/v-sekai-multiplayer-fabric/xr-grid).

### Consequences

- Good: presence and gesture for many people at low per-player cost.
- Good: identity is opt-in through signing, so there is no login step.
- Bad: orbs are not full avatars, so the demo does not exercise avatar networking
  or IK.
- Bad: pen signing depends on cassie, which is a proof-of-concept capability
  (patch surface creation loses about 90%), so the signing path is the weakest
  link.

### Confirmation

A session shows multiple participants, each rendered as a head orb and two hand
orbs tracking their movement, at call scale. Signing with the pen produces a
visible identifying mark next to that participant's orbs.

## More Information

This is the "smallest new piece" milestone: expand the existing single-avatar
`xr-grid` debug scene (one VRM plus placeholder orb clusters) into a populated
room. It composes the [pen-stroke / cassie capability](20260606-feature-classification-poc-baseline-stretch.md)
for optional identity.
