---
title: Presence hexagon — wrapping the existing presence stack
date: 2026-06-11
status: accepted
tier: proof of concept
decision-makers: K. S. Ernest (iFire) Lee
---

## Context and Problem Statement

Remote-avatar presence is already decided in depth: head and hand orbs (the orb demo), human-readable markers (the marker decision), and a ghostly partial body (the body-model decision). The loop needs presence behind ports like the other cores, without redeciding the representation.

## Decision Outcome

Chosen option: wrap the existing presence stack as a thin hexagon. The core interpolates remote head and hand poses between updates and keeps the visual hand separate from the logical combat hand, as a pure reducer.

Driving port: `pose_source` (remote head and hand pose orbs). Driven port: `avatar_sink` (interpolated transforms for the rig). Adapter: `feat/module-xr-grid` feeds `pose_source` over WebTransport and drives the flatscreen path; a fixture adapter replays a recorded pose stream. The marker and body representation follow the existing presence decisions.

## Consequences

- The representation reuses the existing presence decisions, so this hexagon carries no new look.
- This is the thinnest hexagon, foldable into Combat after the gate.
- The pose channel rides its own stream, so a stalled input packet does not delay presence.

## Confirmation

The core replays a recorded pose stream to interpolated transforms, with no network.
