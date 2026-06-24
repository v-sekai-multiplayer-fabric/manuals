---
title: Headless OpenXR testing with Monado (null compositor + simulated HMD)
date: 2026-06-12
status: accepted
decision-makers: K. S. Ernest (iFire) Lee
---

## Context and Problem Statement

The OpenXR path needs to run on Linux without a headset: on the workstation for iteration and in a podman quadlet for CI. Functional and integration coverage of the OpenXR path needs a runnable runtime on the box, with no display and no hardware.

## Decision Outcome

Chosen option: run Monado with the null compositor and a simulated HMD, headless, because it is a conformant OpenXR runtime that an app reaches over the loader with no display and no device, on the workstation and inside a quadlet.

The recipe on Fedora (Monado 25.1.0):

- Install `monado monado-devel monado-vulkan-layers`.
- Select the runtime: symlink `~/.config/openxr/1/active_runtime.json` to `/usr/share/openxr/1/openxr_monado.json`, or set `XR_RUNTIME_JSON`.
- Start the service headless: `tail -f /dev/null | XRT_COMPOSITOR_NULL=1 SIMULATED_ENABLE=1 monado-service`.
- OpenXR clients connect over the IPC socket `$XDG_RUNTIME_DIR/monado_comp_ipc`.

The non-obvious part is the stdin pipe. `monado-service` watches stdin through `epoll` to notice shutdown, and a non-epoll-able stdin (a closed descriptor or a regular file, which is what a background job, a `nohup`, or a container hands it) makes `epoll_ctl(stdin)` fail and the service aborts before it opens the socket. Feeding it an epoll-able pipe (`tail -f /dev/null | ...`, or a held-open FIFO) is what lets it start.

## Consequences

- The OpenXR path runs on the workstation and in a podman quadlet with no display and no headset.
- `XRT_COMPOSITOR_NULL` discards submitted frames, so this covers the runtime, the tracking, and frame submission, with no rendered output and no performance signal.
- `SIMULATED_ENABLE` supplies a head and controllers driven programmatically; the `qwerty` driver (`QWERTY_ENABLE`) adds keyboard and mouse control for an interactive desktop run.
- This is functional and integration coverage; the standalone OpenXR build is the performance and comfort gate.

## Confirmation

`openxr_runtime_list`, and any OpenXR app, reaches `xrCreateInstance` against the running service, and the service log reports the null compositor and a simulated HMD.
