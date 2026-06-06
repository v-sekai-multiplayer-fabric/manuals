---
title: Cut versioned gitassembly tag releases for the assembled engine
date: 2026-06-06
status: proposed
decision-makers: K. S. Ernest Lee
---

## Context and Problem Statement

The [`merge`](https://github.com/v-sekai-multiplayer-fabric/merge) `gitassembly`
recipe builds the engine by merging feature branches (`feat/module-xr-grid`,
`feat/module-cassie`, `feat/module-http3`, and the rest) onto the
[frozen Godot 4.7 base](20260606-pin-engine-to-frozen-godot-4-7.md). The base is
pinned, but the feature branch tips are not: an assembly run today and one next
week can merge different branch SHAs and produce a different engine. The
[cold-boot dependencies](20260606-presence-demo-cold-boot-dependencies.md) refer to
the branches by name, so "assemble these branches" is not yet a reproducible
artifact. How do we name a fixed, shareable point of the assembled engine?

## Decision Drivers

- Reproducibility: a name that resolves to one exact assembled tree, not moving tips.
- A single reference the demo, `godot-images`, and CI can all build from.
- Cheap to cut so releases keep pace with the feature branches.
- Provenance: the tag records the base pin and every merged branch SHA.

## Considered Options

- Keep referring to branch names (status quo); each consumer assembles the tips.
- Tag only the `godot-images` build output, not the source assembly.
- Cut a versioned tag on the assembled branch the `gitassembly` recipe produces.

## Decision Outcome

Chosen option: "Cut a versioned tag on the assembled branch", because it gives one
immutable reference that resolves to an exact tree, while the per-branch SHAs in the
recipe keep the assembly's provenance.

- The recipe assembles the feature branches onto the pinned base and tags the
  result. The tag is annotated and records the base pin SHA and each merged branch
  SHA in its message.
- Tag pattern: `gitassembly-YYYYMMDD-NNNN` — ISO date first so tags sort
  chronologically, with a zero-padded same-day sequence, mirroring the
  [archival naming convention](20260606-archival-file-naming-convention.md).
- The first tag, `gitassembly-20260606-0001`, is the cold-boot reference for the
  presence-marker demo: base `8a337510` (Godot `4.7.0-beta`) with
  `feat/module-xr-grid`, `feat/module-cassie`, and `feat/module-http3` merged.
- Consumers pin to a tag, not to branch names. `godot-images` builds its GHCR
  editor image from a tag, and the cold-boot steps reference that tag.
- A tag is cut whenever a merged branch advances enough to matter; the moving
  branches stay the development surface, and tags are the shareable checkpoints.

### Consequences

- Good: a tag resolves to one exact assembled engine, so demo, image, and CI all
  build the same tree.
- Good: each tag carries the base and branch SHAs, so any assembly is auditable.
- Bad: tags must be cut deliberately, so a stale tag can lag the live branches.

### Confirmation

`git show gitassembly-20260606-0001` lists the base pin and the merged branch SHAs,
and a `godot-images` build from that tag reproduces the same editor. The cold-boot
steps and `godot-images` reference a tag rather than branch names.

## More Information

The tag sits on top of the [engine pin](20260606-pin-engine-to-frozen-godot-4-7.md):
the pin fixes the base, and the tag fixes the assembly merged onto it. It is the
reproducible artifact the [cold-boot dependencies](20260606-presence-demo-cold-boot-dependencies.md)
build from.
