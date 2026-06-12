---
title: Quest 3 immersive deployment requirements
date: 2026-06-12
status: accepted
decision-makers: K. S. Ernest (iFire) Lee
---

## Context and Problem Statement

Exporting the slice to a Quest 3 surfaced several requirements that stock Godot does not satisfy by default, each of which fails in a different, non-obvious way on the device.

## Decision Outcome

Chosen option: the Android export carries four fixes, each confirmed on the device.

- Bundle the Khronos OpenXR loader into the template. Stock Godot dlopens `libopenxr_loader.so` at runtime and ships none, so OpenXR fails to start; a fetch script in [merge](https://github.com/v-sekai-multiplayer-fabric/merge) places the arm64 loader where gradle packages it.
- Declare `com.oculus.intent.category.VR` and `android.hardware.vr.headtracking` on the launcher activity, on `feat/horizonos-immersive`. Without the VR category Horizon hosts the app as a flat 2D panel and the OpenXR session never reaches visible.
- Enable the `INTERNET` permission in the export. Without it the runtime MCP and any listen socket fail to open (`socket() == -1`).
- Fix the forward-mobile vertex shader under `precision=double`, on `feat/double-precision-mobile`. The call sites pass the `vec4` `inv_view_precision` UBO field where `vertex_shader()` takes `vec3`, so every scene shader variant fails to compile and the app dies on launch; the `.xyz` fix matches the clustered renderer.

A screen-state detector reads the VrApi frame heartbeat plus the display power state, so automation tells a black mirror (the Quest sleeps when the proximity sensor is uncovered) from a genuine render fault.

## Consequences

- The Quest export is reproducible from the merged assembly, with the engine fixes on feat branches and the loader step scripted.
- The double-precision client runs on the Quest without origin shifting, consistent with the large-world coordinate approach.

## Confirmation

The APK installs, takes immersive focus (`VrFocusManager` reports it), and the on-device MCP reports a locked 72 Hz with the hub scene rendering ([the Quest 3 gate](20260611-quest-3-frame-floor-as-mvp-gate.md)).
