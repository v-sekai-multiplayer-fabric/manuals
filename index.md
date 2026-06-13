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

This page stays deliberately thin: it links to the decisions that own each fact rather
than restating them, so it does not drift as those decisions change.

## Quick start

The local workflow is bash-first (POSIX shebangs, `/tmp` paths, symlinks, `lsof`, the
UNIX docker socket). On Windows, use WSL2 (Ubuntu).

```sh
git clone https://github.com/v-sekai-multiplayer-fabric/godot
```

The engine assembles from feature branches via
[merge](https://github.com/v-sekai-multiplayer-fabric/merge) and builds through
[godot-images](https://github.com/v-sekai-multiplayer-fabric/godot-images). To build it
locally, follow [Compiling the Godot engine](decisions/20260606-compiling-godot-engine.md).
