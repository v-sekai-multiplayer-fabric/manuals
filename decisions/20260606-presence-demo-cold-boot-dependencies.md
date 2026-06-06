---
title: Cold-boot dependencies for the presence-marker demo
date: 2026-06-06
status: proposed
tier: proof of concept
decision-makers: K. S. Ernest Lee
---

## Context and Problem Statement

The [presence-marker demo](20260606-presence-marker-representation.md) (and its
[ghostly ANNY/SOMA-X body](20260606-ghostly-presence-body-model.md) refinement)
needs a reproducible setup from nothing. What is the minimal dependency set to cold
boot the development environment for it?

## Decision Drivers

- A new machine should reach a running demo from a checkout and a short script.
- Reuse the engine and transport the stack already standardises on.
- Keep the heavy ML pipeline optional until the ghostly body is worked on.

## Decision Outcome

Cold-boot dependencies, by layer:

### 1. Engine (pick one)

- Prebuilt: pull the editor image from
  [godot-images](https://github.com/v-sekai-multiplayer-fabric/godot-images) (GHCR),
  built at the [pinned Godot 4.7 commit](20260606-pin-engine-to-frozen-godot-4-7.md).
- From source: the [compiling SOP](20260606-compiling-godot-engine.md) toolchain
  (`git`, Python 3, SCons, sccache, MinGW-w64 on Windows / `build-essential` on
  Linux), plus [merge](https://github.com/v-sekai-multiplayer-fabric/merge) (Elixir
  `gitassembly`) to assemble `feat/module-xr-grid`, `feat/module-cassie`, and
  `feat/module-http3` onto the pinned base. Check out a
  [gitassembly tag release](20260606-gitassembly-tag-release.md)
  (`v2026.06.06.1853-multiplayer-fabric`) rather than the moving branch tips for a
  reproducible assembly.

### 2. Demo project

- The [xr-grid](https://github.com/v-sekai-multiplayer-fabric/xr-grid) checkout: the
  scene with the skinned-mesh hero-asset landmark and the head/hand pose orbs.

### 3. Networking

- [WebTransport over HTTP/3](20260606-webtransport-http3-transport.md) is compiled
  into the engine (`modules/http3`, picoquic), so local loopback needs nothing
  extra. The Elixir gateway (on V-Sekai-fire) is only needed for call-scale runs.

### 4. Ghostly body pipeline (optional, for the marker upgrade)

- A Python 3 environment with [ANNY](https://github.com/naver/anny) and
  [SOMA-X](https://github.com/NVlabs/SOMA-X) (`py-soma-x`), PyTorch, and NVIDIA Warp
  on a CUDA GPU. Persona and body assets auto-download from Hugging Face.

### 5. VR runtime (optional)

- An OpenXR runtime and headset for in-headset use; the desktop debug window runs
  without one.

### Consequences

- Good: layers 1–2 alone boot a local, single-peer demo; networking and the ML
  body pipeline are additive.
- Bad: the from-source path pulls in an Elixir assembly step and a GPU/PyTorch
  stack, so the full cold boot is heavy.

### Confirmation

A fresh machine reaches the desktop debug window of the xr-grid demo using the
prebuilt engine plus the xr-grid checkout; adding the Python ANNY/SOMA-X stack
enables the ghostly body.

## More Information

Layers reuse the [compiling SOP](20260606-compiling-godot-engine.md), the
[engine pin](20260606-pin-engine-to-frozen-godot-4-7.md), and the
[WebTransport transport](20260606-webtransport-http3-transport.md).
