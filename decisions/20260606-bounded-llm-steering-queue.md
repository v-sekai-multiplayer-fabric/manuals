---
title: Bound the LLM steering queue to avoid context overflow
date: 2026-06-06
status: accepted
tier: baseline
decision-makers: K. S. Ernest (iFire) Lee
---

## Context and Problem Statement

We steer an LLM by appending tasks to a queue as we go — this manuals session is
the canonical example, with dozens of incremental requests. An unbounded queue
overflows two scarce resources: the operator's personal context (you lose track of
what is pending versus done) and the model's context window. How do we keep
steering open-ended without overflowing either?

## Decision Drivers

- Keep adding tasks freely as ideas arrive.
- Bound what is held in volatile conversation context.
- Never lose the record of what was decided or done.

## Considered Options

- Unbounded queue held in the conversation (status quo).
- A hard task cap that drops tasks past a limit.
- Externalize the queue, bound work in progress, and compact finished work.

## Decision Outcome

Chosen option: "Externalize, bound, and compact."

- Externalize: decisions land as MADRs in the manuals and in-flight work as PRs or
  issues. The conversation holds the active item, and the backlog lives in durable,
  searchable storage rather than the transcript.
- Bound work in progress: one concern per PR, merged through the
  [main merge queue](20260606-require-pr-and-merge-queue-on-main.md) before the
  next, so the in-flight set stays small.
- Compact: completed work is folded into durable artifacts (a changelog deck log
  or an MADR) and dropped from the working set, so finished items leave the context
  window. A periodic summary checkpoint resets the working context.

### Consequences

- Good: the backlog and the record live in durable docs, not working memory, so
  the operator's attention and the model's context window both stay bounded.
- Good: each finished item is findable later in the manuals.
- Bad: it takes discipline to externalize and compact instead of holding everything
  in the conversation.

### Confirmation

At any time the conversation holds roughly one active task; completed work is found
in the manuals (decisions and changelog) rather than the transcript; and the number
of open PRs stays small.

## More Information

The merge queue and the one-concern-per-PR rule are the work-in-progress bound; the
changelog and MADR practice is the compaction step.
