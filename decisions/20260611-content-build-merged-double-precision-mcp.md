---
title: Content creation in a single merged double-precision build via the editor MCP
date: 2026-06-11
status: accepted
decision-makers: K. S. Ernest (iFire) Lee
---

## Context and Problem Statement

Content creation needs the full engine, every `feat/*` capability at double precision, without Blender, and the team budgets a single such build for the slice.

## Decision Outcome

Chosen option: produce one Godot build by merging all `feat/*` branches with the `merge` tool at `precision=double` ([the double-precision decision](20260501-godot-double-precision-template-release-for-zone.md), [the compiling decision](20260606-compiling-godot-engine.md)), and drive content creation through the `vsekai-godot-mcp` editor server, where the Godot editor is the MCP server over streamable-HTTP, because one merged build covers authoring and the MCP lets a content tool drive the editor directly. The pipeline uses no Blender ([the CASSIE authoring decision](20260611-cassie-desktop-curvenet-authoring.md)).

## Consequences

- One merged double-precision build covers content authoring for the slice.
- A content tool drives the editor through the MCP over streamable-HTTP.
- The pipeline carries no Blender dependency.

## Confirmation

The merged double-precision build opens and the MCP drives an authoring round trip.
