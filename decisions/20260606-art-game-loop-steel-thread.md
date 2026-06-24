---
title: Recursive art-game loop and its minimal steel thread
date: 2026-06-06
status: proposed
decision-makers: K. S. Ernest (iFire) Lee
tier: proof of concept
---

## Context and Problem Statement

We want a small workspace where friends make tiny art-games together, watch them,
and improve them on a tight loop. Players show up in the space as tracker orbs
(the presence demo), with drawing
pens ([cassie](20260606-feature-classification-poc-baseline-stretch.md)) as a
stretch goal. Before building the workspace out, we need the smallest end-to-end
thread that proves the loop runs at all. What is that thread?

## Decision Drivers

- A tight, local-first feedback loop friends can actually turn.
- Visible results each pass, so friction is obvious.
- One friction note and one patch at a time, not a backlog.
- The smallest path that touches every link from runtime to verified change.

## Considered Options

- Build the full tool-chain and content pipeline first.
- A minimal steel thread that exercises every link once, then grow it.
- Hand-run the loop with no tooling.

## Decision Outcome

Chosen option: "A minimal steel thread that exercises every link once", because it
proves the whole loop end to end before we invest in any one part.

### The recursive art-game loop

1. Friends create a tiny art-game.
2. They play and observe it, capturing friction.
3. We patch the art-game or the tools.
4. We replay the improved version.
5. Repeat.

Players appear as tracker orbs; drawing pens are a stretch goal layered on once the
loop turns.

### The minimal steel thread

1. Start a local Godot runtime/editor.
2. Connect [Godot MCP](https://github.com/v-sekai-multiplayer-fabric/vsekai-godot-mcp).
3. Run one [Godot Sandbox](https://github.com/v-sekai-multiplayer-fabric/godot-sandbox-programs) command/program.
4. Create or modify one visible art object.
5. Record one friction note.
6. Patch one tiny behavior in the art-game or tools.
7. Re-run and verify the visible result changed.

This builds on the [friends-art-game-loop](https://github.com/v-sekai-multiplayer-fabric/friends-art-game-loop)
workspace.

### Consequences

- Good: every link from runtime to verified change is exercised once, so gaps
  surface early.
- Good: the loop produces a visible change and one friction note per pass, which
  keeps scope honest.
- Bad: the first thread is deliberately thin and does no real game design yet.
- Bad: it leans on Godot MCP and the sandbox, so a break in either stalls the loop.

### Confirmation

The steel thread completes from a cold local editor through to a re-run that shows
a changed visible result, with one friction note and one patch recorded.

## More Information

This composes the presence demo
(tracker orbs) and the cassie pen (stretch) into a working loop, run through Godot
MCP and the Godot Sandbox.
