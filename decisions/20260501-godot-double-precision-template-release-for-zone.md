---
title: Godot double precision template_release for zone servers
date: 2026-05-01
status: accepted
decision-makers: K. S. Ernest (iFire) Lee
tier: baseline
---

## Context

Zone servers run the game simulation headlessly. Two Godot build targets are candidates: `editor` (includes import tools) and `template_release` (runtime only). Precision must match the rest of the V-Sekai stack.

## Decision

Build zone server binaries as `target=template_release precision=double` with no Mono. Build from the V-Sekai fork at `V-Sekai-fire/multiplayer-fabric-build@b27142e94`.

## Consequences

- `template_release` has no import or export tools, making it smaller and faster to start.
- `libstdc++-static` must be included in the AlmaLinux 9 build environment because `template_release` links libstdc++ statically.
- The binary filename is `godot.linuxbsd.template_release.double.x86_64`.
- `--headless` flag is required at runtime.
- Double precision matches the physics and networking precision of the rest of the stack.
