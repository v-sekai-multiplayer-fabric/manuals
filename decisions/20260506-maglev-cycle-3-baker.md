# Maglev Cycle 3: Baker Pipeline

## The Context

The Maglev train scene and player VRM avatars must be baked before Cycle 9 (physics replication), which is the first cycle to load actual game assets into the zone server. The baker pipeline runs as an on-demand Fly Machine, depends only on the Fly infrastructure proven in Cycle 1, and can run in parallel with Cycles 6–9.

`multiplayer-fabric-baker` uses Godot in headless editor mode (`godot.linuxbsd.editor.double.x86_64`, built from `multiplayer-fabric-baker` via `ghcr.io/v-sekai-fire/godot-editor-double:latest`) to validate and export scenes. `aria-storage` chunks the output using casync/desync `.caibx` format with zstd compression, uploads chunks to the zone-backend chunk store, and posts the `.caibx` index to uro at `/storage/:id/bake`.

## The Problem Statement

The Cyberprep train environment (MToon shaders, banking train geometry) and the PCVR and Steam Deck VRM avatars have not been validated and stored through the baker pipeline under the Fly deployment. Without baked assets in the chunk store, the zone server in Cycle 9 cannot load the scene.

## Design

Trigger two bake jobs via the Fly Machines API:

1. **Train environment bake**: `multiplayer-fabric-baker` validates the Maglev train scene, exports it, chunks it with aria-storage, and posts the index to uro.
2. **Avatar bake**: same pipeline for the PCVR player VRM and the Steam Deck player VRM.

```bash
flyctl machine run registry.fly.io/multiplayer-fabric-baker:latest \
  --app multiplayer-fabric-baker \
  --env ASSET_ID=<uuid> \
  --env URO_URL=https://hub.chibifire.com \
  -- avatar scenes/<uuid>.tscn out/<uuid>.scn
```

Pass criteria:

- [ ] Both bake jobs exit 0
- [ ] `.caibx` index appears in uro at `/storage/:id/bake` for each asset
- [ ] Zone server can fetch and assemble the train scene from the chunk store before Cycle 9 begins

## Estimate

**3 days** (2026-05-09 → 2026-05-13, parallel). The baker pipeline is in production on Fly (14 days of commits 2026-04-23 to 2026-05-06). The work is Maglev-specific bake config (MToon shader settings, VRM export params) and a Fly Machine invocation test. Art assets are a separate art track not counted here.

## CRIS Score

| Factor          | Score | Evidence                                                                                                                                      |
| --------------- | ----- | --------------------------------------------------------------------------------------------------------------------------------------------- |
| **C**omplexity  | 7     | The baker pipeline is in production use; the only unknowns are the Maglev-specific MToon shader configuration and VRM avatar export settings. |
| **R**each       | 10    | Cycles 10–4 cannot load game assets without baked chunk store entries.                                                                        |
| **I**mpediment  | 9     | A bake failure before Cycle 9 blocks the entire physics and scenario track.                                                                   |
| **S**takeholder | 10    | Required before the first physics cycle and the full Maglev mission scenario.                                                                 |
| **Total**       | 8.75  | Build after Cycle 1 passes, in parallel with Cycles 6–9.                                                                                      |

## The Downsides

Building the Cyberprep environment with MToon shaders tuned for both Steam Deck and PCVR requires dedicated art work. Bake failures surface late if the pipeline is not tested early; running this cycle in parallel with Cycles 6–9 surfaces them while networking cycles are still running.

## The Road Not Taken

Deferring the bake to just before Cycle 9 was rejected — a failed bake stalls the physics track after the networking cycles that preceded Cycle 9 have already completed.

## Status

Status: Draft

## Decision Makers

- Lead Architect / Fabric Maintainer
- Game Director

## Tags

- maglev-cycle-3, baker, aria-storage, vrm, galls-law, 20260506-maglev-cycle-3-baker, present-proposal-template

## Further Reading

```
@techreport{20260501_fly,
  title       = {Fly.io for deployment},
  institution = {V-Sekai Fire},
  year        = {2026},
  type        = {Architecture Decision Record},
  note        = {decisions/20260501-fly-io-for-deployment.md}
}

@techreport{20260506_ghcr,
  title       = {GHCR packages must be built by the repo that consumes them},
  institution = {V-Sekai Fire},
  year        = {2026},
  type        = {Architecture Decision Record},
  note        = {decisions/20260506-ghcr-package-ownership-same-repo.md}
}

@misc{v_sekai_2026,
  title = {V-Sekai},
  year  = {2026},
  url   = {https://v-sekai.org/}
}
```
