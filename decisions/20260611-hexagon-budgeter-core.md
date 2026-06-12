---
title: Budgeter hexagon — core, ports, and adapters
date: 2026-06-11
status: accepted
tier: proof of concept
decision-makers: K. S. Ernest (iFire) Lee
---

## Context and Problem Statement

The slice needs graceful degradation under load on the mobile floor, dialing quality knobs per frame so the player stays inside the experience during a burst.

## Decision Outcome

Chosen option: structure the budgeter as a hexagon. The core is a constraint solver mapping on-device measurements to knob settings — avatar level-of-detail, interpolation against extrapolation, voice radius, and audio sample quality — as a pure reducer; it dials the knobs every frame, never overrules itself, and never dictates how the artists work.

Driving port: `measurement_source` (frame time, thermals, and entity counts). Driven port: `knob_sink` (the settings the runtime applies). Adapters: `feat/module-open-telemetry` feeds `measurement_source`; the engine runtime applies `knob_sink`; a fixture adapter replays a load spike for CI.

## Consequences

- As a hundred extra players land in the hub, the budgeter degrades gracefully, so the player stays inside the experience.
- The solve runs against a recorded spike in CI, so the knob response is testable with no device.
- The budgeter stays advisory, so it never overrules the artists.

## Confirmation

The core replays a recorded load spike and asserts the knob response, with no device under it.
