---
title: Require pull requests and a merge queue on main
date: 2026-06-06
status: accepted
decision-makers: K. S. Ernest (iFire) Lee
tier: baseline
---

## Context and Problem Statement

The `manuals` repo had no branch protection on `main`. Changes landed by pushing
directly or by manually merging pull requests one at a time, with no serialization
between concurrent PRs. As the number of in-flight documentation PRs grows, two
PRs can each pass against an older `main` and then conflict or break the Quarto
build once both land. How should changes reach `main` so that every merge is
reviewable and tested against the tip it will actually join?

## Decision Drivers

- Every change to `main` should arrive through a pull request, not a direct push.
- Concurrent PRs should serialize so each is validated against the latest `main`.
- The team is small, so the process should add little ceremony (no mandatory
  second reviewer).
- The setting should be declarative and recorded, not click-ops folklore.

## Considered Options

- Leave `main` unprotected (status quo).
- Branch protection requiring a pull request only.
- A repository ruleset requiring a pull request plus a merge queue.

## Decision Outcome

Chosen option: "A repository ruleset requiring a pull request plus a merge queue",
because it serializes merges and keeps `main` PR-only without forcing a second
reviewer.

The ruleset targets the default branch with these rules:

- Block branch deletion and non-fast-forward pushes.
- Require a pull request, with `0` required approvals (review is allowed, not
  mandated) and all three merge methods permitted on the PR.
- Require a merge queue using the merge commit method, `ALLGREEN` grouping, up to
  5 entries built and merged per batch, and a 1-minute minimum wait.

### Consequences

- Good: `main` only changes through PRs, and the queue tests each entry against
  the branch tip before it lands.
- Good: the configuration is captured here and reproducible from the ruleset JSON.
- Bad: solo edits now need a PR and an enqueue step.
- Bad: with `0` required approvals, the rule enforces process but not review, so
  an unreviewed PR can still merge.

### Confirmation

The ruleset is active (id `17352485`). `gh api repos/v-sekai-multiplayer-fabric/manuals/rulesets`
lists it, and a direct push to `main` is rejected. Future PRs land via the queue.

## More Information

Created with `gh api -X POST repos/v-sekai-multiplayer-fabric/manuals/rulesets`.
To change the policy, edit the ruleset rather than protecting the branch through
the classic branch-protection API, so the two mechanisms do not overlap.
