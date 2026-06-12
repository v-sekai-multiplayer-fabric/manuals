---
title: CASSIE desktop curvenet authoring for content, no Blender
date: 2026-06-11
status: accepted
decision-makers: K. S. Ernest (iFire) Lee
---

## Context and Problem Statement

The content pipeline needs budget-bounded geometry for the slice without standing up Blender. The `feat/module-cassie` curve-and-surface sketcher produces curve networks that triangulate to a controllable poly count.

## Decision Outcome

Chosen option: author the Hub, the Field, and the enemy as CASSIE curvenets through the desktop path for the deadline, with no Blender, because a curvenet is a bounded, inspectable graph the `zone-baker` can cost, and the desktop path skips the in-headset ergonomics for the one-week build.

## Consequences

- The geometry arrives near budget, so it passes the baker with little rework.
- The in-headset sketching ergonomics land after the gate.
- The pipeline carries no Blender dependency.

## Confirmation

The authored Hub and Field pass the `zone-baker` at budget.
