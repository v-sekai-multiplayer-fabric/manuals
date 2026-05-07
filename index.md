# V-Sekai Fire — Multiplayer Fabric

Documentation for the multiplayer fabric stack: a WebTransport-based game server platform built on Godot, Elixir, and CockroachDB, deployed on Fly.io.

- Source code: [V-Sekai-fire on GitHub](https://github.com/V-Sekai-fire)
- Issues and discussion: [multiplayer-fabric-taskweft](https://github.com/V-Sekai-fire/multiplayer-fabric-taskweft)
- Top-level monorepo: [multiplayer-fabric](https://github.com/V-Sekai-fire/multiplayer-fabric) (this is the umbrella that registers every repo below as a submodule)

## Repositories

### Runtime services (Fly.io)

| Repo                                                                                                                 | Purpose                                                                                                          |
| -------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| [multiplayer-fabric-gateway](https://github.com/V-Sekai-fire/multiplayer-fabric-gateway)                             | Elixir WebTransport gateway on UDP 443 — entry point for all clients                                             |
| [multiplayer-fabric-zone](https://github.com/V-Sekai-fire/multiplayer-fabric-zone)                                   | Headless Godot zone server (template_release, double precision)                                                  |
| [multiplayer-fabric-zone-backend](https://github.com/V-Sekai-fire/multiplayer-fabric-zone-backend)                   | Phoenix backend (uro): shard registry, asset API. Submodule path: `multiplayer-fabric-uro`                       |
| [multiplayer-fabric-zone-console](https://github.com/V-Sekai-fire/multiplayer-fabric-zone-console)                   | Operator console for zone server health and shard rotations                                                      |
| [multiplayer-fabric-crdb](https://github.com/V-Sekai-fire/multiplayer-fabric-crdb)                                   | CockroachDB with mTLS, role-separated access (gateway_writer / gateway_reader / gateway_admin / root)            |
| [multiplayer-fabric-baker](https://github.com/V-Sekai-fire/multiplayer-fabric-baker)                                 | On-demand Fly Machine that validates and exports Godot assets via aria-storage                                   |
| [multiplayer-fabric-observability](https://github.com/V-Sekai-fire/multiplayer-fabric-observability)                 | VictoriaMetrics (8428) + VictoriaLogs (9428) + VictoriaTraces (10428) + OTEL Collector (4317/4318) on supervisord |

### Engine

| Repo                                                                                                                 | Purpose                                                                                                          |
| -------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| [multiplayer-fabric-godot](https://github.com/V-Sekai-fire/multiplayer-fabric-godot)                                 | V-Sekai fork of the Godot engine — feature branches per topic, assembled output lives on `multiplayer-fabric-base` |
| [multiplayer-fabric-godot-maglev](https://github.com/V-Sekai-fire/multiplayer-fabric-godot-maglev)                   | Canonical assembled engine snapshot used as `git subrepo` source by `multiplayer-fabric-build`                   |
| [multiplayer-fabric-merge](https://github.com/V-Sekai-fire/multiplayer-fabric-merge)                                 | `gitassembly` recipe + `update_godot_v_sekai.exs` driver that composes the engine from its feature branches      |
| [multiplayer-fabric-build](https://github.com/V-Sekai-fire/multiplayer-fabric-build)                                 | Engine build orchestrator (Justfile + per-platform CI matrix); vendors engine source under `godot/` via git-subrepo |
| [opentelemetry-godot](https://github.com/V-Sekai-fire/opentelemetry-godot)                                           | OTLP/HTTP exporter module for the Godot engine — compiled into the assembly via `feat/open-telemetry-base`        |
| [opentelemetry-godot-project](https://github.com/V-Sekai-fire/opentelemetry-godot-project)                           | Godot project demonstrating + testing the OTel module in isolation                                               |
| [multiplayer-fabric-webtransport](https://github.com/V-Sekai-fire/multiplayer-fabric-webtransport)                   | Elixir bindings for the Rust [wtransport](https://github.com/BiagioFesta/wtransport) WebTransport library         |
| [multiplayer-fabric-interaction-system](https://github.com/V-Sekai-fire/multiplayer-fabric-interaction-system)       | XR controller / 6-DOF IK helper addon                                                                            |
| [multiplayer-fabric-interaction-system-project](https://github.com/V-Sekai-fire/multiplayer-fabric-interaction-system-project) | Godot project that exercises the interaction-system addon                                                        |

### Game systems

| Repo                                                                                                                 | Purpose                                                                                                          |
| -------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| [multiplayer-fabric-taskweft](https://github.com/V-Sekai-fire/multiplayer-fabric-taskweft)                           | Re-entrant temporal HTN planner + ReBAC engine (Elixir/C++20 NIFs)                                               |
| [multiplayer-fabric-predictive-bvh](https://github.com/V-Sekai-fire/multiplayer-fabric-predictive-bvh)               | Predictive BVH adapter for spatial queries — used by the zone server's broadphase                                |
| [multiplayer-fabric-predictive-bvh-research](https://github.com/V-Sekai-fire/multiplayer-fabric-predictive-bvh-research) | Lean 4 formalization + correctness proofs for the predictive BVH                                                 |
| [aria-storage](https://github.com/V-Sekai-fire/aria-storage)                                                         | casync/desync chunked content-addressable storage (Elixir wrapper around vendored Go binary)                     |
| [multiplayer-fabric-humanoid-project](https://github.com/V-Sekai-fire/multiplayer-fabric-humanoid-project)            | Humanoid avatars + animations (`mire.vrm` is the canonical Maglev test avatar)                                   |
| [elixir-turboquant-llm](https://github.com/V-Sekai-fire/elixir-turboquant-llm)                                       | Quantized LLM inference NIF (Elixir / llama.cpp). Submodule path: `multiplayer-fabric-llm`                       |

### Infrastructure & tooling

| Repo                                                                                                                 | Purpose                                                                                                          |
| -------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| [multiplayer-fabric-infra](https://github.com/V-Sekai-fire/multiplayer-fabric-infra)                                 | Terraform for Fly.io resources (apps, IPs, volumes, secrets) + read-only verify workflows                        |
| [docker-multiplayer-fabric](https://github.com/V-Sekai-fire/docker-multiplayer-fabric)                               | Dockerfiles for zone-fabric, baker, uro runtime images                                                           |
| [multiplayer-fabric-hosting](https://github.com/V-Sekai-fire/multiplayer-fabric-hosting)                             | Self-hosted hosting recipes (Caddy, versitygw, docker-compose stack)                                             |
| [multiplayer-fabric-generate-secrets](https://github.com/V-Sekai-fire/multiplayer-fabric-generate-secrets)           | Shared secret-generation helpers (mTLS PKI bootstrap, JWT keys)                                                  |
| [multiplayer-fabric-elf-programs](https://github.com/V-Sekai-fire/multiplayer-fabric-elf-programs)                   | RISC-V ELF programs run inside the engine's `module_sandbox`                                                     |
| [multiplayer-fabric-casync-seed](https://github.com/V-Sekai-fire/multiplayer-fabric-casync-seed)                     | Pre-baked casync chunk store seed for fast cold-start asset assembly                                             |
| [cockroach](https://github.com/V-Sekai-fire/cockroach)                                                               | Vendored CockroachDB source (build inputs for the multiplayer-fabric-crdb Docker image)                          |

### Testing & verification

| Repo                                                                                                                 | Purpose                                                                                                          |
| -------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| [multiplayer-fabric-cycle-tests](https://github.com/V-Sekai-fire/multiplayer-fabric-cycle-tests)                     | Maglev cycle smoke tests — minimal headless Godot scripts, one per cycle                                          |

### Skills & docs

| Repo                                                                                                                 | Purpose                                                                                                          |
| -------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| [manuals](https://github.com/V-Sekai-fire/manuals)                                                                   | This site (Quarto). Submodule path: `multiplayer-fabric-manuals`                                                  |
| [multiplayer-fabric-skills](https://github.com/V-Sekai-fire/multiplayer-fabric-skills)                               | Reusable Claude Code skills shared across the fabric repos                                                       |
