---
title: Two-org split between V-Sekai-fire and v-sekai-multiplayer-fabric
date: 2026-06-06
status: accepted
---

## Context and Problem Statement

The repository map in `index.md` described a single org, `V-Sekai-fire`, built
around a `multiplayer-fabric` submodule umbrella whose repos were named
`multiplayer-fabric-*`. The stack has since grown a second GitHub org,
[`v-sekai-multiplayer-fabric`](https://github.com/v-sekai-multiplayer-fabric),
which now hosts the engine, the Harvester VM images, the rendering and USD
research, and these manuals. The two orgs use different repo names, and the old
repos do not redirect into the new org. The documentation map had drifted far
enough from reality that a reader could not find the live repos.

How should the manuals represent the stack while both orgs are in active use?

## Decision Drivers

- The map has to point at repos that actually resolve.
- Historical decision records and changelog entries link to `V-Sekai-fire`
  repos that still exist; those links must keep working.
- New work happens in `v-sekai-multiplayer-fabric`, so that org should read as
  the primary home.
- The migration is partial. Several services have not moved.

## Considered Options

- Rewrite every `V-Sekai-fire` reference to `v-sekai-multiplayer-fabric`.
- Document `v-sekai-multiplayer-fabric` as the home org and keep a marked
  cross-org section for the repos still under `V-Sekai-fire`.
- Leave the map untouched and add a disclaimer.

## Decision Outcome

Chosen option: "Document `v-sekai-multiplayer-fabric` as the home org and keep a
marked cross-org section", because it gives readers an accurate map of the live
org without breaking the historical record.

Concretely:

- `index.md` lists the `v-sekai-multiplayer-fabric` repos grouped by role, then a
  "Still on V-Sekai-fire" section for the repos that have not migrated.
- Living docs (`index.md`, `_quarto.yml`, `AGENTS.md`) name the new org.
- Decision records and changelog entries keep their `V-Sekai-fire` links, which
  still resolve.

### Migration status

| Role             | V-Sekai-fire (old)                         | v-sekai-multiplayer-fabric (new)    |
| ---------------- | ------------------------------------------ | ----------------------------------- |
| Engine           | multiplayer-fabric-godot                   | godot                               |
| Engine merge     | multiplayer-fabric-merge                   | merge                               |
| Engine build     | multiplayer-fabric-build                   | godot-images                        |
| Zone server      | multiplayer-fabric-zone                    | zone-server (+ zone-server-image)   |
| Zone backend     | multiplayer-fabric-zone-backend            | zone-backend (+ zone-backend-image) |
| Baker            | multiplayer-fabric-baker                   | zone-baker (+ zone-baker-image)     |
| Observability    | multiplayer-fabric-observability           | observability                       |
| Database         | multiplayer-fabric-crdb                    | cockroach-crdb-image                |
| Infra            | multiplayer-fabric-infra                   | infra (Harvester HCI)               |
| Spatial proofs   | multiplayer-fabric-predictive-bvh-research | lean-predictive-bvh                 |
| Sandbox programs | multiplayer-fabric-elf-programs            | godot-sandbox-programs              |

Not yet migrated, still under V-Sekai-fire: gateway, zone-console, webtransport,
taskweft, humanoid-project, aria-storage, elixir-turboquant-llm, cycle-tests, and
the `multiplayer-fabric` umbrella.

### Consequences

- Good: every repo link in the map resolves, and new contributors land in the
  right org.
- Good: the historical record stays intact and citable.
- Bad: the stack is described across two orgs until migration finishes, so the
  map needs upkeep as repos move.

### Confirmation

A link check over `index.md` resolves all repo URLs. The "Still on V-Sekai-fire"
section shrinks as repos migrate; each move updates the table above.

## More Information

The deployment target is also shifting, from Fly.io to a self-hosted Harvester
HCI cluster running each service as a podman-quadlet VM image. See the
`infra` repo's `docs/migration-status.md` for that progress.
