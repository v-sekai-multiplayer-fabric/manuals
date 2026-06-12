---
title: Progression hexagon — core, ports, and adapters
date: 2026-06-11
status: accepted
tier: proof of concept
decision-makers: K. S. Ernest (iFire) Lee
---

## Context and Problem Statement

The profile and inventory rules — the profile, the valid inventory transitions, and the affinity gate on arts — need to be durable across a session and testable with no database.

## Decision Outcome

Chosen option: structure progression as a hexagon. The core defines the profile and the inventory, the valid transitions, and the affinity gate, as a pure reducer.

Driving port: `profile_source` (a profile load at login). Driven port: `commit_sink` (a durable write of the profile and the inventory). Adapters: `zone-backend` with `cockroach` commits through the mTLS store ([the CockroachDB decision](20260501-cockroachdb-with-mtls-role-separation.md)); `feat/module-sqlite` caches on the instance and stands in as a degraded commit; a fixture adapter holds a recorded profile for CI.

## Consequences

- The persistence degrades from the `cockroach` adapter to the `feat/module-sqlite` adapter behind one `commit_sink`, so a slipping commit path is not blocking the loop.
- Inventory transitions validate in the core, so a bad transition fails a fixture rather than a live write.
- The affinity gate holds an art out of reach below its requirement.

## Confirmation

The core validates inventory transitions against a recorded profile fixture, and a drop commits through the adapter and survives a round trip.
