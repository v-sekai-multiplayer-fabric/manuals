---
title: First-party curated content with zone-baker budgets
date: 2026-06-11
status: accepted
tier: baseline
decision-makers: K. S. Ernest (iFire) Lee
---

## Context and Problem Statement

A user-generated-content runtime carries arbitrary, unpredictable per-frame cost, which is fatal on a mobile GPU holding a stereo VR frame. The MVP needs predictable cost and the freedom to co-optimize content against the engine.

## Decision Outcome

Chosen option: ship first-party curated content only, with no user-generated-content runtime, and let the `zone-baker` enforce hard budgets at bake time, because curated content lets the engine co-optimize with the art and lets the baker reject anything over budget before it reaches a device.

## Consequences

- A four-player Field room holds its geometry, four avatars, and props under roughly 500,000 visible triangles and 200 draw calls per eye on the standalone VR build.
- The baker rejects any asset that exceeds the budget, so cost stays predictable.
- The content surface stays small, which keeps the determinism and the budgeter tractable.

## Confirmation

Every shipped asset passes the `zone-baker` at budget, and a four-player room holds the per-eye limits on the standalone VR build.
