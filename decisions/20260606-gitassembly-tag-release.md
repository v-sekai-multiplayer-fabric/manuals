---
title: Cut gitassembly tag releases for the assembled engine
date: 2026-06-06
status: accepted
decision-makers: K. S. Ernest (iFire) Lee
---

## Context and Problem Statement

The [`merge`](https://github.com/v-sekai-multiplayer-fabric/merge) repo's
`gitassembly` recipe builds the engine by merging feature branches
(`feat/module-xr-grid`, `feat/module-cassie`, `feat/module-http3`, and the rest)
onto the [frozen Godot 4.7 base](20260606-pin-engine-to-frozen-godot-4-7.md). The
base is pinned, but the feature branch tips are not: an assembly run today and one
next week can merge different branch SHAs and produce a different engine. The
cold-boot dependencies refer to
the branches by name, so "assemble these branches" alone is not a reproducible
artifact. What is the shareable, fixed reference for the assembled engine?

## Decision Drivers

- Reproducibility: a name that resolves to one exact assembled tree, not moving tips.
- A single reference the demo, `godot-images`, and CI can all build from.
- Cheap to cut so releases keep pace with the feature branches.
- Do not steamroll prior assemblies that other work already builds against.

## Considered Options

- Keep referring to branch names; each consumer assembles the tips itself.
- Force-push the assembled `multiplayer-fabric` branch as the shared reference.
- Push an immutable, timestamped tag of the assembled tree (the existing
  `merge` tooling already does this).

## Decision Outcome

Chosen option: "Push an immutable, timestamped tag", because it gives one reference
that resolves to an exact tree without overwriting prior assemblies. This adopts the
behavior the `merge` tooling already implements rather than inventing a new scheme.

- `elixir update_godot_v_sekai.exs` (run from `main`) fetches the remotes, runs the
  vendored `git-assembler` over the `gitassembly` recipe, then tags the assembled
  `multiplayer-fabric` branch and pushes **only the tag** to
  `v-sekai-multiplayer-fabric/godot`. The moving branch stays local, so a release
  never steamrolls anyone working off a previous tip.
- Tag format (CalVer, UTC): `v<YYYY.MM.DD.HHMM>-multiplayer-fabric`. The timestamp
  is the only thing that changes between runs; the assembler is deterministic, so
  the same inputs produce the same tree.
- The current cold-boot reference is `v2026.06.06.1853-multiplayer-fabric`
  (commit `9ea526ab`), assembled onto the pinned 4.7 base with the full recipe,
  including `feat/module-xr-grid`, `feat/module-cassie`, and `feat/module-http3`.
- Consumers pin to a tag, not to branch names. `godot-images` builds its GHCR
  editor image from a tag, and the cold-boot steps
  reference that tag.
- Iterate with `--dry-run` (assembles locally, no push) before cutting a release.

### Consequences

- Good: a tag resolves to one exact assembled engine, so demo, image, and CI build
  the same tree.
- Good: tag-only push keeps every prior assembly intact and addressable.
- Bad: the CalVer tag carries no semantic version, so the assembled Godot version
  is implicit in the [pinned base](20260606-pin-engine-to-frozen-godot-4-7.md).
- Bad: tags must be cut deliberately, so a stale tag can lag the live branches.

### Confirmation

`git ls-remote --tags v-sekai-multiplayer-fabric/godot` lists
`v<YYYY.MM.DD.HHMM>-multiplayer-fabric` tags, a `godot-images` build from a tag
reproduces the same editor, and the cold-boot steps reference a tag rather than
branch names.

## More Information

The tag sits on top of the [engine pin](20260606-pin-engine-to-frozen-godot-4-7.md):
the pin fixes the base, and the tag fixes the assembly merged onto it. It is the
reproducible artifact the cold-boot dependencies
build from. The tag format and workflow are documented in the `merge` repo's
`CONTRIBUTING.md`.
