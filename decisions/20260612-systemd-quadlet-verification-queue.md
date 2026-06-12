---
title: Verification smokes as a systemd podman quadlet queue
date: 2026-06-12
status: accepted
decision-makers: K. S. Ernest (iFire) Lee
---

## Context and Problem Statement

The slice's smokes — headless OpenXR, loot wire parity, combat wire parity, four-player contention — need to run as a repeatable queue on the workstation and on self-hosted runners, with ordering, logs, and per-job status, and the deployment decision already standardizes on podman quadlets.

## Decision Outcome

Chosen option: run each smoke as a oneshot quadlet `.container` unit, serialized with `After=` into a `fabric-verify.target`, because systemd supplies the queue, the journal, and the status surface with no extra orchestrator. A small `fabric-smoke` image (Fedora plus fontconfig) runs the headless smokes; the merged double-precision Godot binary, the smoke scripts, and the Lean golden vectors bind-mount read-only, so the image stays generic and the artifacts stay host-owned. Every smoke asserts against Lean-emitted golden vectors, pinned by Plausible properties in the cores.

## Consequences

- `systemctl --user start fabric-verify.target` runs the whole queue; `systemctl --user status 'fabric-smoke-*'` and the journal carry the results.
- The units install by file copy into `~/.config/containers/systemd`, matching the quadlet deployment convention.
- A failing smoke fails its unit, so the queue surfaces regressions per stage rather than as one opaque script.

## Confirmation

The target runs all four smokes to success under systemd on the workstation. The image, the runners, and the units live in [fabric-verify](https://github.com/v-sekai-multiplayer-fabric/fabric-verify).
