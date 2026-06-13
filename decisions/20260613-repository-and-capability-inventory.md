---
title: Repository and capability inventory for the multiplayer fabric
date: 2026-06-13
status: accepted
tier: baseline
decision-makers: K. S. Ernest (iFire) Lee
---

## Context and Problem Statement

The landing page used to carry the full repository list, a capability-to-branch
table, and a prose description of the deployment target. Those facts already have
homes — each capability rides a decision and an engine branch, the deployment target
is a decision, the two-org split is a decision — so the landing page was a second
copy that drifted every time one of those decisions changed. This record is the one
place that owns the org-wide inventory; the landing page links here instead of
restating it, and decided facts (deployment, org split, per-capability status) stay
in their own decisions.

The narrower [vertical-slice repository map](20260612-vertical-slice-repository-map.md)
indexes only the loot-action slice; this inventory is the full
[`v-sekai-multiplayer-fabric`](https://github.com/v-sekai-multiplayer-fabric) org plus
the repos still on [`V-Sekai-fire`](https://github.com/V-Sekai-fire).

## Decision Outcome

This page is the canonical inventory. Each capability maps to the engine feature
branch in [godot](https://github.com/v-sekai-multiplayer-fabric/godot) that implements
it; the Tier column follows the
[feature classification](20260606-feature-classification-poc-baseline-stretch.md).

### Capabilities and where they live

| Capability                                                                               | Tier             | Engine branch                                                                        | Supporting repos                                                                                                                                                                                                             | Status                                                                                |
| ---------------------------------------------------------------------------------------- | ---------------- | ------------------------------------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------- |
| Native video playback                                                                    | Baseline         | `feat/native-media` (MediaFoundation, GStreamer)                                     | [native-media-test](https://github.com/v-sekai-multiplayer-fabric/native-media-test), [vulkan-video-godot](https://github.com/v-sekai-multiplayer-fabric/vulkan-video-godot)                                                 | Working; builds on Windows and Linux.                                                 |
| Networking transport ([WebTransport / HTTP/3](20260606-webtransport-http3-transport.md)) | Baseline         | `feat/module-http3` (picoquic + web/wasm backends)                                   | [zone-server](https://github.com/v-sekai-multiplayer-fabric/zone-server)                                                                                                                                                     | Working; `WebTransportPeer`/`QUICClient`/`QUICServer`, demos, Lean termination proof. |
| Scene baking via OpenUSD                                                                 | Baseline         | —                                                                                    | [openusd-fabric](https://github.com/v-sekai-multiplayer-fabric/openusd-fabric), [zone-baker](https://github.com/v-sekai-multiplayer-fabric/zone-baker), [idtx-flow](https://github.com/v-sekai-multiplayer-fabric/idtx-flow) | Working; USD schema, Blender export hooks, scene validation, headless export.         |
| Spatial audio ([HRTF + audio probes](20260606-spatial-audio-patched-resonance-audio.md)) | Baseline         | `feat/spatial-audio-server`, `feat/module-resonance-audio` (patched Resonance Audio) | [sponza-godot-audio](https://github.com/v-sekai-multiplayer-fabric/sponza-godot-audio)                                                                                                                                       | Working; demo and benchmark scene.                                                    |
| Speech                                                                                   | Baseline         | `feat/module-speech`                                                                 | —                                                                                                                                                                                                                            | Working.                                                                              |
| Pen stroke creation (codename cassie)                                                    | Proof of concept | `feat/module-cassie`                                                                 | [vsekai-materialx](https://github.com/v-sekai-multiplayer-fabric/vsekai-materialx), [materialx-shaders-lean](https://github.com/v-sekai-multiplayer-fabric/materialx-shaders-lean)                                           | Pen stroke creation is solid; patch surface creation is buggy (loses about 90%).      |
| Multiplayer presence ([tracker orbs](20260606-multiplayer-presence-demo-orbs.md))        | Proof of concept | `feat/module-xr-grid`                                                                | [xr-grid](https://github.com/v-sekai-multiplayer-fabric/xr-grid)                                                                                                                                                             | Proposed; head and hand pose orbs sent over low-level WebTransport.                   |

### Repositories — `v-sekai-multiplayer-fabric`

#### Engine

| Repo                                                                                                             | Purpose                                                                                                        |
| ---------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------- |
| [godot](https://github.com/v-sekai-multiplayer-fabric/godot)                                                     | V-Sekai fork of the Godot engine. Feature branches per topic.                                                  |
| [merge](https://github.com/v-sekai-multiplayer-fabric/merge)                                                     | `gitassembly` recipe and `update_godot_v_sekai.exs` driver that composes the engine from its feature branches. |
| [godot-images](https://github.com/v-sekai-multiplayer-fabric/godot-images)                                       | Single-source-of-truth engine builds: editor (baker) and template_release (zone server). Publishes to GHCR.    |
| [godot-sandbox-gdscript-compiler](https://github.com/v-sekai-multiplayer-fabric/godot-sandbox-gdscript-compiler) | GDScript-to-sandbox compiler for the engine's `module_sandbox`.                                                |
| [godot-sandbox-programs](https://github.com/v-sekai-multiplayer-fabric/godot-sandbox-programs)                   | RISC-V programs run inside `module_sandbox` (fork).                                                            |
| [native-media-test](https://github.com/v-sekai-multiplayer-fabric/native-media-test)                             | Godot project exercising the engine's native media (audio/video) backend.                                      |
| [vulkan-video-godot](https://github.com/v-sekai-multiplayer-fabric/vulkan-video-godot)                           | Vulkan Video decode integration for Godot (placeholder).                                                       |

#### Runtime services

| Repo                                                                         | Purpose                                                                        |
| ---------------------------------------------------------------------------- | ------------------------------------------------------------------------------ |
| [zone-server](https://github.com/v-sekai-multiplayer-fabric/zone-server)     | Headless Godot zone server (template_release, double precision).               |
| [zone-backend](https://github.com/v-sekai-multiplayer-fabric/zone-backend)   | URO: Phoenix/Elixir backend for identity, the zone directory, and the planner. |
| [zone-baker](https://github.com/v-sekai-multiplayer-fabric/zone-baker)       | Minimal headless Godot project that validates and exports VSK assets.          |
| [observability](https://github.com/v-sekai-multiplayer-fabric/observability) | VictoriaMetrics, VictoriaLogs, Tempo, and the OTEL Collector.                  |

#### Service images

Each service ships as an OCI container image launched by a podman quadlet under
systemd; see [run services as systemd podman quadlets on Fedora 44](20260613-quadlets-on-fedora-44-instead-of-harvester.md),
which supersedes the earlier qcow2-on-Harvester model. The `*-image` repos below are
being repointed from qcow2 VM images to OCI images per that decision.

| Repo                                                                                       | Purpose                                                                                 |
| ------------------------------------------------------------------------------------------ | --------------------------------------------------------------------------------------- |
| [linux-base-image](https://github.com/v-sekai-multiplayer-fabric/linux-base-image)         | Shared base image with podman, chrony, and a guest agent. Base for every service image. |
| [zone-server-image](https://github.com/v-sekai-multiplayer-fabric/zone-server-image)       | Headless Godot zone server runtime image.                                               |
| [zone-baker-image](https://github.com/v-sekai-multiplayer-fabric/zone-baker-image)         | Headless Godot asset validator and exporter image.                                      |
| [zone-backend-image](https://github.com/v-sekai-multiplayer-fabric/zone-backend-image)     | URO Phoenix backend image.                                                              |
| [cockroach-crdb-image](https://github.com/v-sekai-multiplayer-fabric/cockroach-crdb-image) | CockroachDB server image (v-sekai fork).                                                |
| [restic-backup-image](https://github.com/v-sekai-multiplayer-fabric/restic-backup-image)   | versitygw, restic, and a cockroach client for the backup image.                         |
| [gha-runner-image](https://github.com/v-sekai-multiplayer-fabric/gha-runner-image)         | Org-wide GitHub Actions self-hosted runner as a podman quadlet.                         |
| [sccache-cache-image](https://github.com/v-sekai-multiplayer-fabric/sccache-cache-image)   | versitygw S3 endpoint dedicated to sccache for fast C++ rebuilds.                       |

#### Rendering, shaders, and USD

| Repo                                                                                           | Purpose                                                                                                      |
| ---------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------ |
| [godot-toon-shaders](https://github.com/v-sekai-multiplayer-fabric/godot-toon-shaders)         | Godot toon shader ports and a shared parameter map (MToon 0.x / MToon10, planned SCSS and lilToon).          |
| [vsekai-materialx](https://github.com/v-sekai-multiplayer-fabric/vsekai-materialx)             | PBR/NPR/Slug as MaterialX nodes compiled to Slang; ThorVG-to-Slug vectorization, differentiable via SlangPy. |
| [materialx-shaders-lean](https://github.com/v-sekai-multiplayer-fabric/materialx-shaders-lean) | Lean 4 formalization of PBR, NPR, and vector shaders under MaterialX.                                        |
| [MaterialX](https://github.com/v-sekai-multiplayer-fabric/MaterialX)                           | The MaterialX material-exchange standard (fork).                                                             |
| [idtx-flow](https://github.com/v-sekai-multiplayer-fabric/idtx-flow)                           | Godot plugin importing USD via openUSD (fork).                                                               |
| [openusd-fabric](https://github.com/v-sekai-multiplayer-fabric/openusd-fabric)                 | OpenUSD pipeline spanning Blender, Godot, Hydra, Unity, and a Lean schema.                                   |
| [sponza-godot-audio](https://github.com/v-sekai-multiplayer-fabric/sponza-godot-audio)         | Sponza demo and audio benchmark for Godot 4.                                                                 |

#### Spatial and verification

| Repo                                                                                     | Purpose                                                                       |
| ---------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------- |
| [lean-predictive-bvh](https://github.com/v-sekai-multiplayer-fabric/lean-predictive-bvh) | Lean 4 formal verification and codegen for the Predictive BVH spatial oracle. |

#### Tooling and integration

| Repo                                                                               | Purpose                                                                               |
| ---------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------- |
| [vsekai-godot-mcp](https://github.com/v-sekai-multiplayer-fabric/vsekai-godot-mcp) | In-editor MCP server addon for Godot (Streamable-HTTP, constant-work command buffer). |
| [viser](https://github.com/v-sekai-multiplayer-fabric/viser)                       | Web-based 3D visualization in Python (fork).                                          |
| [xr-grid](https://github.com/v-sekai-multiplayer-fabric/xr-grid)                   | VR interaction tool (fork).                                                           |

#### Infrastructure and docs

| Repo                                                             | Purpose                                                                                      |
| ---------------------------------------------------------------- | -------------------------------------------------------------------------------------------- |
| [infra](https://github.com/v-sekai-multiplayer-fabric/infra)     | OpenTofu config that provisions the self-hosted hosts and delivers the podman-quadlet units. |
| [manuals](https://github.com/v-sekai-multiplayer-fabric/manuals) | This Quarto site.                                                                            |

#### Archived

| Repo                                                                                                 | Purpose                                 |
| ---------------------------------------------------------------------------------------------------- | --------------------------------------- |
| [friends-art-game-loop](https://github.com/v-sekai-multiplayer-fabric/friends-art-game-loop)         | Local-first art-game loop experiment.   |
| [sandbox-gdextension-godot](https://github.com/v-sekai-multiplayer-fabric/sandbox-gdextension-godot) | Earlier GDExtension sandbox approach.   |
| [usd-converter-for-vrchat](https://github.com/v-sekai-multiplayer-fabric/usd-converter-for-vrchat)   | VRChat-to-VRM 1.0 converter UPM (fork). |

### Still on `V-Sekai-fire` (not yet migrated)

These repos remain the source of truth under the older org; see the
[two-org split](20260606-org-split-v-sekai-multiplayer-fabric.md). Links in the
decisions and changelog that point at them are correct and still resolve.

| Repo                                                                                                       | Purpose                                                             |
| ---------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------- |
| [multiplayer-fabric](https://github.com/V-Sekai-fire/multiplayer-fabric)                                   | Umbrella monorepo registering the V-Sekai-fire repos as submodules. |
| [multiplayer-fabric-gateway](https://github.com/V-Sekai-fire/multiplayer-fabric-gateway)                   | Elixir WebTransport gateway on UDP 443.                             |
| [multiplayer-fabric-zone-console](https://github.com/V-Sekai-fire/multiplayer-fabric-zone-console)         | Operator console for zone health and shard rotations.               |
| [multiplayer-fabric-webtransport](https://github.com/V-Sekai-fire/multiplayer-fabric-webtransport)         | Elixir bindings for the Rust wtransport library.                    |
| [multiplayer-fabric-taskweft](https://github.com/V-Sekai-fire/multiplayer-fabric-taskweft)                 | Re-entrant temporal HTN planner and ReBAC engine.                   |
| [multiplayer-fabric-humanoid-project](https://github.com/V-Sekai-fire/multiplayer-fabric-humanoid-project) | Humanoid avatars and animations (`mire.vrm` test avatar).           |
| [aria-storage](https://github.com/V-Sekai-fire/aria-storage)                                               | casync/desync chunked content-addressable storage.                  |
| [elixir-turboquant-llm](https://github.com/V-Sekai-fire/elixir-turboquant-llm)                             | Quantized LLM inference NIF (Elixir / llama.cpp).                   |
| [multiplayer-fabric-cycle-tests](https://github.com/V-Sekai-fire/multiplayer-fabric-cycle-tests)           | Maglev cycle smoke tests, one per cycle.                            |

## Consequences

- One page owns the inventory, so a repo or capability change lands in one place.
- The landing page asserts only durable orientation and links here, so it no longer
  drifts when the deployment target, org split, or a capability status changes.
- This inventory still needs hand maintenance; the gain is a single source of truth,
  not zero maintenance.
