---
title: MCP runtime bridge for deployed builds
date: 2026-06-12
status: accepted
decision-makers: K. S. Ernest (iFire) Lee
---

## Context and Problem Statement

The Godot MCP addon is an editor plugin, so it drives the editor over its `EditorInterface`. Debugging a deployed build — a headless zone server, a mobile client, a Quest 3 app — needs the same inspection against the running game, where there is no editor.

## Decision Outcome

Chosen option: a runtime autoload (`mcp_runtime.gd`) serves the same MCP from inside the running game, injecting the live `SceneTree` where the editor plugin injects the editor. An MCP client reaches it over `adb forward` (or any port forward). Scene, node, property, `call_method`, `run_script`, `get_render_info`, and a runtime-capable `screenshot` operate on the running game; editor-only commands return an error.

The contribution lands upstream as [vsekai-godot-mcp#1](https://github.com/v-sekai-multiplayer-fabric/vsekai-godot-mcp/pull/1).

## Consequences

- A deployed Quest build is inspectable and drivable from the workstation: frame stats, the live scene tree, and arbitrary GDScript against the running game.
- Under XR, `screenshot` reads the flat Window viewport, which is black because the rendered frames go to the XR compositor's per-eye swapchain and that is not host-readable; `get_render_info` and `run_script` cover XR diagnostics instead.

## Confirmation

On a Quest 3 over `adb forward`, `get_render_info` returns 13 draw calls and 46476 primitives from the running app, and `run_script` reads the live client state (peer id, connection, phase).
