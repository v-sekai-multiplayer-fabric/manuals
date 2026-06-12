---
title: Loot hexagon — core, ports, and adapters
date: 2026-06-11
status: accepted
tier: proof of concept
decision-makers: K. S. Ernest (iFire) Lee
---

## Context and Problem Statement

Loot generation and first-touch contention need to be deterministic and replayable, so a drop and its winner reproduce from the seed and the receipt order.

## Decision Outcome

Chosen option: structure loot as a hexagon. The core rolls drops from loot tables keyed by enemy type and difficulty using a seeded generator, and resolves first-touch contention by receipt timestamp, granting the first requester and rejecting the rest, as a pure reducer over deterministic state.

Driving port: `loot_request_source` (an interact event with a receipt timestamp and a requester id). Driven ports: `grant_sink` (the award or rejection per requester), `inventory_delta_sink` (the change to persist). Adapters: the `zone-server` orders requests by receipt; the progression persistence adapter applies `inventory_delta_sink`; a fixture adapter replays contention races for CI.

## Consequences

- The Hub shop degrades to a free starting kit behind this core, so a slipping economy is not blocking the loop.
- The roll reproduces from the seed in the state.
- Contention resolves on the server, so two clients see one winner.

## Confirmation

The core replays a recorded contention race to one grant against the rest rejected, with no network.
