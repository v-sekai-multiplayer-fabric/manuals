---
title: YAGNI times structure to the need, in code and in the record
date: 2026-06-29
status: accepted
decision-makers: K. S. Ernest (iFire) Lee
---

# YAGNI times structure to the need, in code and in the record

## The Context

Kent Beck's [The Cost YAGNI Was Never About](https://newsletter.kentbeck.com/p/the-cost-yagni-was-never-about) reframes YAGNI as a question of timing rather than thrift. Building structure ahead of the feature that needs it sends two bills: optionality, because committing on a guess spends the option to build the right thing once the need is known; and net present value, because the cost lands early while the return lands late. Both bills survive cheap code generation, since neither one is the price of typing.

Two artifacts in this stack carried speculative structure of that kind. The `build_msix` script had cross-platform branches for hosts that never run it. Several decision records carried CRIS score tables and other ceremony around the decision they recorded.

## The Problem Statement

Cheap generation makes speculative structure easy to produce, and it reads as diligence. Code and decision records can accrete structure ahead of need, which carries both bills and crowds the load-bearing parts.

## Design

Adopt YAGNI as a question of timing.

- Build structure when the feature that needs it arrives. The rule is about timing, so a real near-term need is met by building now.
- Keep a decision record to the load-bearing sections set by the MADR proposal template: context, problem, design, downsides, the road not taken, and how the decision is confirmed.
- When a record stops describing the live plan, mark it superseded and move it to `_archive`, following `_archive/README.md`.

## The Downsides

- A timing judgment can defer something whose need turns out to be near. The rule is about timing, so the response is to build once the need is real.
- Trimming and archiving move breadth of context out of the live listing. The archive keeps that history in the repository.

## The Road Not Taken

- Read YAGNI as effort-saving, so that cheap code retires it. The essay rejects this reading: the bills are optionality and net present value, and cheap generation leaves both intact.

## Confirmation

The principle was applied in three changes: the ceremony trim across the heavy decision records, this pass archiving the superseded presence demo, and the `build_msix` script trimmed to the two platforms it serves. Each change left the working behaviour unchanged.
