# Game-loop-first cluster sequence

## The Context

The team polled on which cluster to build next. Game-loop won (2 of 4, 50%). uiux polish, Cassie pen-mesh, shop economy, and OpenUSD i/o all depend on a working loop and cannot be integration-tested without it.

## The Problem Statement

No agreed delivery sequence across the three remaining clusters, risking polish and content work landing on an unstable loop and blocking the feedback release.

## Design

Cut a SteamVR build for external feedback.

## CRIS Score

| Factor          | Score | Evidence                                                             |
| --------------- | ----- | -------------------------------------------------------------------- |
| **C**omplexity  | 2     | Sequencing decision only; no new implementation work ordered here    |
| **R**each       | 10    | Sets the delivery order for all remaining vertical-slice work        |
| **I**mpediment  | 9     | Without a fixed sequence, uiux and content risk blocking the release |
| **S**takeholder | 9     | Poll-validated (2 of 4, 50%); release date depends on this order     |
| **Total**       | 7.5   | Accept and hold                                                      |

## The Downsides

Cluster 3 waits until after the feedback release. If game-loop slips the whole sequence slides with no parallel path to absorb delay.

## The Road Not Taken

Parallel clusters and content-first were considered; both risk landing polish or authoring work on a loop that is still changing.

## Status

Status: Accepted

## Decision Makers

- K. S. Ernest (iFire) Lee

## Tags

- loot-action, cluster-sequence, game-loop, uiux, content, release, 20260624-game-loop-cluster-sequence
