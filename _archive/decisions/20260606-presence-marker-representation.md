---
title: Human-readable presence markers with an orb debug mode
date: 2026-06-06
status: superseded by 20260611-loot-action-core-loop-mvp-vertical-slice.md
tier: proof of concept
decision-makers: K. S. Ernest (iFire) Lee
consulted: Joseph
---

## Context and Problem Statement

The orb presence demo draws each
participant as head and hand orb clusters. In review, the orbs read as too similar:
a head cluster and a hand cluster look alike, so they are easy to conflate, and a
bare cluster conveys position better than heading. The 3-point model and the
networking are sound; the visual marker is the weak part. What should the default
marker be?

![The `xr-grid` debug scene: each remote participant drawn as head and hand orb clusters. These become the debug mode. [@vsekai_xrgrid_debug_2026]](attachments/20260606_vsekai-mpf_xr-grid-debug-orbs_0001.png)

## Decision Drivers

- Tell head from hands at a glance.
- Convey heading (orientation), not only position.
- Keep the cheap 3-point pose and its compact wire format.
- Keep a raw view for debugging.

## Considered Options

- Raw orb clusters as the default (current).
- A vague ghostly or cartoony head plus distinct hand markers that show heading.
- A floating "TV head" showing the user's Steam avatar.

## Decision Outcome

Chosen option: "A vague ghostly or cartoony head plus distinct hand markers". The
default marker is a soft humanoid head that shows position and heading, with hand
markers shaped differently from the head so the three points stay legible. The raw
orb clusters stay as a debug mode the viewer can flip to.

- Default: a ghostly/cartoony head (position + heading) and distinct hand markers.
- Debug: the orb clusters from the superseded demo, toggleable.
- Stretch: a floating TV head showing the user's Steam avatar.
- Unchanged: 3-point tracking, poses over
  [WebTransport datagrams](20260606-presence-demo-networking-internals.md) in a
  compact binary form, and [cassie](20260606-feature-classification-poc-baseline-stretch.md)
  pen signing for optional identity.

### Consequences

- Good: head and hands are distinguishable, and heading is visible.
- Good: the orb mode is kept for debugging the underlying poses.
- Bad: the humanoid and hand markers are assets that have to be authored and shipped.

### Confirmation

A session shows each participant as a heading-bearing head marker and distinct hand
markers; a debug toggle falls back to the orb clusters.

## More Information

Supersedes Minimal multiplayer presence demo with head and hand orbs.
The orb representation is retained as the debug mode. UX input from Joseph. Refined by
[Ghostly partial-body presence avatar from ANNY via SOMA-X](20260606-ghostly-presence-body-model.md).
