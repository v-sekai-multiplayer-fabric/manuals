---
title: CI/CD runners operate as a finite queueing system
date: 2026-06-11
status: accepted
decision-makers: K. S. Ernest (iFire) Lee
tier: baseline
---

## Context and Problem Statement

The organization shares one GitHub Actions runner pool across every repository,
observed at roughly 14–20 concurrent jobs. A single push to the Godot fork
triggers a matrix of about 20 jobs, and the slowest of them (sanitizer and
Windows builds) hold a runner for one to two hours. Pushes arrive from fix
branches, pull requests, merge commits, reruns, and even archive repositories
that carry the same workflow files. When arrivals outpace the pool, every
queued job waits behind work that may carry no information at all. How does CI
work get admitted to the runner pool so that signal arrives quickly?

## Decision Drivers

- The pool is a queueing system with a small fixed number of servers: as
  utilization approaches saturation, waiting time grows without bound
  (M/M/c behaviour), and the delay hits short high-signal jobs as hard as long
  ones.
- One logical change can spawn several full matrices: a branch push and its
  pull request double-trigger, the merge push triggers again, and a rerun
  repeats whatever already ran.
- Some queued work is known in advance to produce nothing: a job whose fix is
  not on the branch yet fails with certainty, and a run on a merged or deleted
  ref validates nothing.
- Diagnostics need CI hardware (a crash that only reproduces on GCC Linux
  runners) but not the whole matrix.

## Considered Options

- Unbounded admission: push and rerun freely, let GitHub queue everything.
- Hard concurrency caps in workflow configuration (per-repo `concurrency`
  groups beyond the existing per-branch cancellation).
- An operating discipline that bounds arrivals at the source: batch, sequence,
  and cancel zero-information work.

## Decision Outcome

Chosen option: "an operating discipline that bounds arrivals at the source",
because the waste comes from how work is submitted, not from how GitHub
schedules it — and a discipline adapts per situation where a hard cap blocks
urgent work behind stale work.

The discipline:

- Two or three full matrices run at a time; further work waits for a slot. A
  merge push waits until the in-flight run it would concurrency-cancel
  finishes, so partially-completed long jobs are not thrown away mid-service.
- Arrivals are batched: fixes land as one commit per push where possible, and
  a late-discovered fix joins an already-open PR branch rather than opening a
  new one. One merge then validates the whole batch with a single matrix.
- Zero-information runs are cancelled immediately: the push-event run that
  duplicates a PR's pull-request run, runs still queued on merged or deleted
  refs, runs whose remaining jobs have a known outcome, and workflow runs
  triggered by pushes to archive repositories (Actions stays disabled on
  `godot-archived`).
- Diagnostics are trimmed to one job: a throwaway branch edits the workflow
  down to the single job that reproduces the problem, and reuses the warm
  build cache by keeping the matrix entry's `cache-name`. The branch is
  deleted once the answer is in hand.
- A failed job whose fix is not yet on the branch never reruns; until the fix
  lands it would occupy a server for its full service time and return a result
  that is already known.
- Backlog is admitted selectively: stale branches needing fresh signal enter
  the queue worst-first, one or two at a time, when utilization is low rather
  than as a bulk rerun.

### Consequences

- Good: high-signal jobs spend their time in service, not in queue; verdicts
  on key jobs arrive in roughly the service time of the job itself.
- Good: the merge policy (merge on a passing key job) composes cleanly —
  batched PRs mean each merge buys validation for several fixes with one
  matrix.
- Bad: sequencing adds wall-clock latency to individual merges; a merge-ready
  PR waits for an unrelated in-flight run to finish.
- Bad: the discipline lives in operator habit and this record, not in enforced
  configuration; a contributor who pushes freely still floods the pool.

### Confirmation

The discipline is in practice on the CHI-364 CI campaign: six redundant queued
runs cancelled in one sweep (two merged PRs' leftovers, a deleted tag's run, a
push/PR duplicate), Actions disabled on `godot-archived` after an archive push
was found competing with the main repo's queue, a GCC-only segfault diagnosed
through a single-job trimmed workflow over four iterations on a warm cache, and
fixes batched so that two branches reached green with one validation matrix
each.

## More Information

The queue is observable with
`gh run list --repo <repo> --json databaseId,status,headBranch` filtered to
`queued`/`in_progress`, and per-run job counts with
`gh run view <id> --json jobs`. Little's law gives the sanity check: jobs in
system ≈ arrival rate × time in system, so when queued jobs exceed the server
count several times over, every new matrix admits about an hour of added
latency to its own verdict.
