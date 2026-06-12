---
title: Loot-action core-loop MVP vertical slice
date: 2026-06-11
status: accepted
tier: proof of concept
decision-makers: K. S. Ernest (iFire) Lee
---

## Context and Problem Statement

The fabric needs a first playable that exercises the whole stack end to end: a social hub, an instanced combat zone, and the round trip between them, on the Quest 3. The team needs one bounded target small enough for a one-week build yet complete enough to prove the loop.

## Decision Outcome

Chosen option: ship one vertical slice of an instanced, four-player loot-action core loop, because a single bounded loop proves the transport, the authority, the persistence, and the budget together without an open content surface.

In scope:

**One Hub deck with a shop, a four-player party teleporting into one Field room, the melee archetype with a timed combo against one enemy, one loot drop, and persistence of the result.**

Out of scope:

More Fields, boss fights, the full economy, trading, and avatar customization. The deadline is 2026-06-18, and AI generates the cores, the fixtures, the adapters, and the content in parallel while the squad reviews and integrates.

## Consequences

- The slice proves the loop on the Quest 3 frame floor with placeholder content.
- The ranged archetype, the caster archetype, the second platforms, and the in-headset authoring land after the gate.
- The build follows the hexagonal core/ports/adapters structure, per [the hexagonal decision](20260610-hexagonal-core-ports-adapters.md), with one core per loop concern behind narrow ports.

## Confirmation

The slice is complete when a four-player party forms on the Hub, clears the enemy, grabs one drop under first-touch contention, and returns with the result committing to the store, at 72 Hz on a Quest 3.
