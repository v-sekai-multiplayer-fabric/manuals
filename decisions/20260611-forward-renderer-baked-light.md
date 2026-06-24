---
title: Forward renderer with baked light for the mobile floor
date: 2026-06-11
status: accepted
decision-makers: K. S. Ernest (iFire) Lee
---

## Context and Problem Statement

The mobile tile renderer rations bandwidth across file, memory, and network IO, and deferred rendering competes for it. The slice needs predictable frame cost regardless of light count.

## Considered Options

- Deferred rendering.
- A simple forward renderer with baked global illumination.

## Decision Outcome

Chosen option: a simple forward renderer with baked global illumination and light probes for static geometry, a dedicated shadow pass for avatars, and probe lighting for dynamic entities, because the frame cost stays predictable regardless of light count. Deferred rendering pressures the bandwidth the mobile tile renderer rations.

## Consequences

- Frame cost stays predictable, so artists place many lights without watching the budget.
- Dynamic entities take lower-fidelity probe lighting.
- The renderer removes one axis the small team otherwise tunes by hand.

## Confirmation

The Field room holds the frame floor on the standalone VR build with many lights placed.
