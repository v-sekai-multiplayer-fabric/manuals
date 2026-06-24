---
title: Repository map of the loot-action vertical slice
date: 2026-06-12
status: accepted
decision-makers: K. S. Ernest (iFire) Lee
---

## Context and Problem Statement

The [loot-action core-loop slice](20260611-loot-action-core-loop-mvp-vertical-slice.md) spans more than a dozen repositories: a playable app, one Lean core per loop concern, the wire and transport specs, the engine fork and its assembly recipe, the verification queue, and the docs. A reader who clones one repo sees one slice of the whole and has no single place that says which repository owns which concern and how they compose into a deployable build.

## Decision Drivers

- The slice follows the [hexagonal core/ports/adapters structure](20260610-hexagonal-core-ports-adapters.md), so each loop concern lives behind its own narrow port in its own repository.
- The cores are pure reducers proven in Lean+Plausible, separate from the engine that hosts them.
- The engine fork assembles from independent `feat/*` branches through a recipe, so the runtime binary has no single source repository.

## Decision Outcome

Chosen option: one repository owns each concern, and this map is the index. Every repository below lives in the [`v-sekai-multiplayer-fabric`](https://github.com/v-sekai-multiplayer-fabric) organization.

### The playable slice

- [`loop-slice`](https://github.com/v-sekai-multiplayer-fabric/loop-slice) — the GDScript app: hub deck, party teleport, the timed combo against one enemy, first-touch loot contention, and the round trip that commits the result. The text protocol is transport-agnostic, so `TRANSPORT=enet` drives the local slice and `TRANSPORT=wt` drives the WebTransport path over the same protocol.

### The domain hexagons and their Lean cores

Each loop concern carries a hexagon (`core/` + `ports/` + `adapters/`) and a standalone Lean workspace holding the canonical core:

- combat: [`combat`](https://github.com/v-sekai-multiplayer-fabric/combat) hexagon, [`combat-core`](https://github.com/v-sekai-multiplayer-fabric/combat-core) Lean core (combo timing, the enemy spawn-invulnerability window, hit validation, damage).
- loot: [`loot`](https://github.com/v-sekai-multiplayer-fabric/loot) hexagon, [`loot-core`](https://github.com/v-sekai-multiplayer-fabric/loot-core) Lean core (the seeded weighted roll and first-touch contention, with a lean-slang SPIR-V kernel).
- progression: [`progression`](https://github.com/v-sekai-multiplayer-fabric/progression) hexagon, [`progression-core`](https://github.com/v-sekai-multiplayer-fabric/progression-core) Lean core (profile and inventory rules, the persistence commit).

### The wire, transport, and determinism specs (Lean+Plausible)

- [`entity_packet`](https://github.com/v-sekai-multiplayer-fabric/entity_packet) — the integral 100-byte entity transform packet (int64 micrometers, no origin shift), with a roundtrip and size proof and a C++ differential.
- [`http3-queue`](https://github.com/v-sekai-multiplayer-fabric/http3-queue) — the WebTransport transport concurrency model: a mutex-guarded inbound queue proven size-honest, and a starvation-free network-thread loop ([the persistent-stream decision](20260612-webtransport-persistent-framed-stream.md)).
- [`connection-fsm`](https://github.com/v-sekai-multiplayer-fabric/connection-fsm) — the client-server connection lifecycle, proven sound and recovering inside the five-second transaction limit.
- the predictive spatial oracle and the proof hexagons that rode alongside it, split out of the now-archived [`lean-predictive-bvh`](https://github.com/v-sekai-multiplayer-fabric/lean-predictive-bvh) monorepo into one repository per hexagon cluster along the dependency seams:
  - [`lean-spatial-oracle`](https://github.com/v-sekai-multiplayer-fabric/lean-spatial-oracle) — the predictive BVH and its R128 fixed-point, the velocity scale the entity packet binds to (ghost expansion, SAH, and Hilbert broadphase, emitting `predictive_bvh.h` through the AmoLean codegen).
  - [`lean-shared-core`](https://github.com/v-sekai-multiplayer-fabric/lean-shared-core) — the shared primitive types every cluster core builds on, dependency-free so the others require it without pulling Mathlib.
  - [`lean-rebac-core`](https://github.com/v-sekai-multiplayer-fabric/lean-rebac-core) — the NoGod / ReBAC authorization core.
  - [`lean-humanoid-rom`](https://github.com/v-sekai-multiplayer-fabric/lean-humanoid-rom) — humanoid range-of-motion and IK constraints (Kusudama, muscle and prismatic limits), with the body-model and biomechanics citations.
  - [`lean-fabric-protocol`](https://github.com/v-sekai-multiplayer-fabric/lean-fabric-protocol) — the fabric networking and SLA proofs: saturation, waypoint bounds, and the abyssal SLA.
  - [`lean-interest-mgmt`](https://github.com/v-sekai-multiplayer-fabric/lean-interest-mgmt) — authority-interest and solve-order: who-sees-whom and solve sequencing.

### The engine and its assembly

- [`godot`](https://github.com/v-sekai-multiplayer-fabric/godot) — the double-precision fork. Each module rides its own `feat/*` branch (for example `feat/module-http3` carries WebTransport and the mbedtls ECDSA crypto, `feat/module-xr-grid` carries the orientation orbs, `feat/module-sqlite` carries the progression store).
- [`merge`](https://github.com/v-sekai-multiplayer-fabric/merge) — the `gitassembly` recipe and the git-assembler driver that stage and merge every `feat/*` branch into the `multiplayer-fabric` assembly, then tag the result. The branch stays local; the tag is the durable artifact.
- [`godot-archived`](https://github.com/v-sekai-multiplayer-fabric/godot-archived) — branches the assembly drops, such as `crypto-extensions`, whose crypto lives in `feat/module-http3`.

### Verification, tooling, and docs

- [`fabric-verify`](https://github.com/v-sekai-multiplayer-fabric/fabric-verify) — the verification smokes as a systemd podman quadlet queue, gating the cores against their golden vectors.
- [`vsekai-godot-mcp`](https://github.com/v-sekai-multiplayer-fabric/vsekai-godot-mcp) — the in-editor and runtime MCP addon that drives a deployed build over adb.
- [`xr-grid`](https://github.com/v-sekai-multiplayer-fabric/xr-grid) — the VR interaction tool whose orientation orbs render the peers in the slice.
- [`tropes-action`](https://github.com/v-sekai-multiplayer-fabric/tropes-action) — the static house-style check the manuals run.
- [`manuals`](https://github.com/v-sekai-multiplayer-fabric/manuals) — these decisions, the changelog, and the reference docs.

## Consequences

- A reader starts here, follows one link to the concern they care about, and finds a self-contained repository.
- A core proves itself in its own Lean workspace, the engine hosts it through a flat-C adapter, and the slice wires the hexagons together, so a change to one concern stays in one repository.
- The runtime binary is reproducible from the pushed `feat/*` branches through the `merge` recipe, so no single clone holds the whole engine and none needs to.

## Confirmation

An OpenXR build assembles from the `multiplayer-fabric` assembly, joins the `loop-slice` server over the wire, and completes a Hub-to-Field-to-Loot round that commits progression, exercising the cores, the wire, the transport, and the persistence together.
