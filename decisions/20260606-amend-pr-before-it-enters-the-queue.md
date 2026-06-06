---
title: Amend a PR before it enters the merge queue, not after
date: 2026-06-06
status: accepted
decision-makers: K. S. Ernest (iFire) Lee
---

## Context and Problem Statement

The [merge queue](20260606-require-pr-and-merge-queue-on-main.md) captures a PR's
head commit the moment its checks pass and it is enqueued. While drafting the
[gitassembly tag MADR](20260606-gitassembly-tag-release.md), a correction was pushed
to the PR branch seconds after enqueueing; the queue had already snapshotted the
earlier commit, so it merged the draft and orphaned the fix. The correction had to
land as a [second PR](20260606-gitassembly-tag-release.md). How should a late fix to
an in-flight PR be sequenced so it is not lost to the queue?

## Decision Drivers

- A pushed correction must be the commit that actually merges.
- Avoid a follow-up PR that exists only to redo a missed fix.
- Keep the cost of the rule near zero for the common case (no late fix).

## Considered Options

- Push the fix and assume the queue picks up the new tip (status quo that failed).
- Confirm the PR is still `OPEN` after the corrective push, before relying on it.
- Dequeue the PR, push the fix, then re-enqueue.

## Decision Outcome

Chosen option: "Confirm `OPEN` after the push, and dequeue first when already
enqueued", because once a PR is in the queue a later push races the merge.

- Do not enqueue a PR until it is final. Enqueue (`gh pr merge --auto`) is a commit
  that the next change is ready, not a parking spot.
- If a fix is needed after enqueueing, dequeue first (`gh pr merge --disable-auto`),
  push the fix, then re-enqueue.
- After any corrective push to an in-flight PR, verify it is still `OPEN`
  (`gh pr view <n> --json state`) before assuming the new commit will merge; a
  `MERGED` state means the fix was missed and needs its own PR.

### Consequences

- Good: the commit that merges is the one intended, with no orphaned fixes.
- Good: no redundant follow-up PRs to reapply a missed correction.
- Bad: a small habit of checking state or dequeuing adds a step when editing a
  PR that is already in flight.

### Confirmation

A late fix to an enqueued PR is preceded by a dequeue or followed by an `OPEN`
state check; the merged commit on `main` contains the fix, with no follow-up PR
that only reapplies it.

## More Information

This refines the [merge queue policy](20260606-require-pr-and-merge-queue-on-main.md)
and is the work-in-progress discipline the
[bounded steering queue](20260606-bounded-llm-steering-queue.md) relies on: one
finished concern per PR, merged before the next.
