---
title: Spatial audio via a patched Resonance Audio (HRTF and audio probes)
date: 2026-06-06
status: accepted
tier: baseline
---

## Context and Problem Statement

The zone server renders shared social-VR scenes where sound sources need to be
localized in 3D for every listener. Two things drive presence: binaural HRTF
rendering so a source is heard at the correct azimuth and elevation over
headphones, and audio probes that capture how a room colors and occludes sound so
a source baked behind a wall does not leak through it. Godot's built-in
`AudioServer` does stereo panning and attenuation, but it has no HRTF path and no
probe-based spatialization. How should the engine produce HRTF spatial audio with
environmental probes?

## Decision Drivers

- Binaural HRTF output for headphone VR.
- Audio probes for environmental response and occlusion, bakeable per scene.
- Double-precision engine build; the audio module has to link into the fork.
- Reuse a proven spatialization library rather than writing one.

## Considered Options

- Godot built-in `AudioServer` panning only.
- Steam Audio (Valve) integration.
- A patched Resonance Audio integrated as an engine module plus a spatial-audio
  server.

## Decision Outcome

Chosen option: "A patched Resonance Audio integrated as an engine module", because
it provides HRTF binaural rendering and ambisonic room response with an
open-source base the fork can carry, and it slots into the engine as a module
rather than a runtime GDExtension.

The implementation lives on two engine feature branches:

- `feat/module-resonance-audio` — the patched Resonance Audio vendored as an
  engine module, exposing HRTF binaural rendering and audio probes.
- `feat/spatial-audio-server` — the spatial-audio server that drives the module,
  placing sources and listeners and resolving probes per frame.

[sponza-godot-audio](https://github.com/v-sekai-multiplayer-fabric/sponza-godot-audio)
is the demo and benchmark scene.

### Consequences

- Good: headphone listeners get correct HRTF localization, and probes give rooms
  a consistent response with occlusion.
- Good: the module links into the double-precision fork and ships with the engine
  assembly.
- Neutral: the fork carries a patch set against Resonance Audio, but the rebase
  burden is low. Upstream is abandoned (Google archived the project), so there are
  no upstream changes to track, and the engine is pinned to a frozen Godot 4.7
  commit, so the module does not chase engine movement. The fork owns the code.
- Bad: HRTF and probe resolution add per-frame audio cost that the spatial-audio
  server has to budget.

### Confirmation

The two branches assemble into the engine and the `sponza-godot-audio` scene
renders HRTF output with probes. The capability is tracked in the
[index capabilities table](../index.md#capabilities-and-where-they-live).

## More Information

Resonance Audio is Google's open-source spatial audio SDK
(<https://resonance-audio.github.io/resonance-audio/>), now archived and no longer
maintained upstream, so the fork is the de facto source. "Patched" here means the
fork carries local changes to build it as an engine module and to wire its HRTF
and probe paths to the spatial-audio server. The engine itself is pinned to a
frozen Godot 4.7 commit, so the module targets a fixed engine API.
