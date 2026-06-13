# V-Sekai — Multiplayer Fabric

A WebTransport game-server platform built on Godot, Elixir, and CockroachDB. The
runtime is self-hosted; see the [deployment decisions](decisions.qmd) for the current
target.

The project spans two GitHub organizations:
[`v-sekai-multiplayer-fabric`](https://github.com/v-sekai-multiplayer-fabric) is the
home for new work, and [`V-Sekai-fire`](https://github.com/V-Sekai-fire) holds the
runtime services not yet migrated. See the
[two-org split decision](decisions/20260606-org-split-v-sekai-multiplayer-fabric.md)
for how they relate, and the
[repository and capability inventory](decisions/20260613-repository-and-capability-inventory.md)
for where each repo lives today.

## Where things live

| Resource                                                                  | Contents                                                   |
| ------------------------------------------------------------------------- | ---------------------------------------------------------- |
| [Decisions](decisions.qmd)                                                | Architecture decision records (MADR) — the source of truth |
| [Repositories](decisions/20260613-repository-and-capability-inventory.md) | Canonical repo and capability inventory                    |
| [Changelog](changelog.qmd)                                                | Daily deck logs                                            |
| [References](references.qmd)                                              | Bibliography of cited sources                              |
| [Compiling the engine](decisions/20260606-compiling-godot-engine.md)      | Local build SOP for Godot                                  |
