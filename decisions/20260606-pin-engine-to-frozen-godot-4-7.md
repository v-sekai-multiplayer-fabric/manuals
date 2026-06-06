---
title: Pin the engine to a frozen Godot 4.7 commit
date: 2026-06-06
status: accepted
---

## Context and Problem Statement

The engine fork carries many feature branches (cassie, resonance audio, native
media, speech, spatial audio, the fabric modules) that the `merge` recipe
assembles onto a base. If that base tracks a moving upstream, every assembly can
shift under the patches, so a green build one day can break the next from upstream
churn alone. What base should the feature branches and the assembly build on?

## Decision Drivers

- A stable base so assembly and CI are reproducible.
- Patch branches that do not have to chase upstream API changes mid-cycle.
- A known engine version for the docs and for downstream images.

## Considered Options

- Track upstream `godotengine/godot` `master`.
- Track an upstream release branch.
- Pin the fork's `master` to one frozen upstream Godot 4.7 commit.

## Decision Outcome

Chosen option: "Pin the fork's `master` to one frozen upstream Godot 4.7 commit",
because it gives the patch branches and the assembly a fixed target, so builds are
reproducible and upstream churn cannot break an assembly.

- The fork's `master` is the frozen base. Its tip is `8a337510` (Godot
  `4.7.0-beta`, per `version.py`).
- Every feature branch in the [`merge`](https://github.com/v-sekai-multiplayer-fabric/merge)
  `gitassembly` recipe stands alone on `master`; the recipe merges them onto the
  assembled branch from that base.
- The pin moves only by a deliberate update to `master`, not by following
  upstream.

### Consequences

- Good: assemblies and CI are reproducible against a fixed engine.
- Good: feature branches target one fixed engine API.
- Bad: upstream fixes after the pin are not picked up until `master` is advanced
  on purpose.
- Bad: the longer the pin sits on a beta, the larger the eventual catch-up to a
  later 4.7.

### Confirmation

`version.py` on the fork reports `4.7.0-beta`, and the `gitassembly` recipe bases
its branches on `master`. Advancing the engine is a single, reviewable change to
the `master` pin.

## More Information

This pin is why the [spatial audio decision](20260606-spatial-audio-patched-resonance-audio.md)
notes the module targets a fixed engine API. The exact upstream commit that
`master` mirrors lives in the godot fork's git history.
