# Release tags progress chronologically through dev, beta, rc, and release

## The Context

`fabric-godot-packaging` produces native Linux packages, a Podman quadlet
package, a Quest 3 APK, and Windows MSIXes for the loot-action loop-slice.
All build workflows are manually dispatched (`workflow_dispatch`) and accept a
`version` input. Until now there was no defined convention for what version
strings to use at each stage of a build's lifecycle, no incrementable counter
within a stage, and no agreed way to list tags in progression order.

A first attempt used `v0.1.0-dev`, which has no counter and cannot be
incremented without replacing the tag. A second attempt used numeric stage
prefixes (`v0.1.0-1dev.001`, `v0.1.0-2beta.001`) to force lexicographic
ordering, which is functionally correct but visually noisy. A third attempt
zero-padded the counter (`v0.1.0-dev.001`) to preserve within-stage
lexicographic order, which is unnecessary once creator-date sort is adopted.

## The Problem Statement

Without a convention, operators choose version strings ad hoc. The result is
tags that neither sort in progression order nor communicate the build's
readiness at a glance. Lexicographic and semver-style sorting both fail to
produce the correct stage order for the names `dev`, `beta`, `rc` (since
`'b' < 'd'`, `beta` precedes `dev` alphabetically even though it follows it
in the pipeline).

## Design

**Tag format**

Semver pre-release identifiers (same scheme as Kubernetes, Node.js, Rust):

```
v<major>.<minor>.<patch>-<stage>.<N>   # pre-release
v<major>.<minor>.<patch>               # final release
```

| Stage   | Example tag     |
| ------- | --------------- |
| dev     | `v0.1.0-dev.1`  |
| beta    | `v0.1.0-beta.1` |
| rc      | `v0.1.0-rc.1`   |
| release | `v0.1.0`        |

The counter (`1`, `2`, …) is unpadded — zero-padding (`001`) was only needed
for lexicographic ordering within a stage, which is unnecessary once
creator-date sort is adopted.

**Ordering**

Tags are always created in forward chronological order (dev builds precede
beta, beta precedes rc, rc precedes the release tag). Correct progression
order is therefore recovered with:

```sh
git tag --sort=creatordate
```

Neither `sort` nor `git tag --sort=version:refname` gives the correct
cross-stage order for these names — `beta` precedes `dev` alphabetically and
bare `v0.1.0` precedes all suffixed forms as a string prefix — so creator date
is the authoritative sort key.

**Workflow inputs**

The `version` workflow input maps directly to `LOOP_PKG_VERSION`. Pass the
stage suffix when dispatching pre-release builds:

```
version: 0.1.0-dev.1    # → LOOP_PKG_VERSION=0.1.0-dev.1
version: 0.1.0-beta.1   # → LOOP_PKG_VERSION=0.1.0-beta.1
version: 0.1.0-rc.1     # → LOOP_PKG_VERSION=0.1.0-rc.1
version: 0.1.0            # → LOOP_PKG_VERSION=0.1.0  (final release)
```

The build scripts already treat any version containing `-` as a prerelease
(`--prerelease` flag on `gh release create`); bare versions produce a full
release.

**Tagging procedure**

After a successful workflow run, tag the packaging repo commit that produced
the artifacts:

```sh
git tag v0.1.0-dev.1
git push origin v0.1.0-dev.1
```

## CRIS Score

| Factor          | Score | Evidence                                                                                       |
| --------------- | ----- | ---------------------------------------------------------------------------------------------- |
| **C**omplexity  | 10    | Convention only — no tooling changes; existing scripts already handle the `-` prerelease flag  |
| **R**each       | 7     | Applies to every build artifact across all five release workflows                              |
| **I**mpediment  | 5     | Absence causes ad-hoc tags; workaround is operator discipline, which is unreliable over time   |
| **S**takeholder | 6     | External testers and the release pipeline both depend on readable, ordered version identifiers |
| **Total**       | 7     | Schedule soon                                                                                  |

## The Downsides

- `git tag --sort=creatordate` requires discipline: a tag created out of order
  (e.g. a hotfix rc tag applied after the release tag) will appear in the
  wrong position. There is no enforcement mechanism.
- Within a stage, counter values above 9 sort before 2–9 under plain string
  sort (`dev.10` < `dev.2`). This is only a problem if plain `sort` is used;
  `--sort=creatordate` is unaffected.

## The Road Not Taken

**Numeric stage prefixes** (`v0.1.0-1dev.1`, `v0.1.0-2beta.1`) — force
correct lexicographic order without depending on creator date. Rejected
because the numeric prefix is visually noisy and unfamiliar to readers who did
not write the convention.

**Zero-padded counter** (`v0.1.0-dev.001`) — preserves within-stage
lexicographic order for counters ≥ 10. Rejected because creator-date sort
makes padding unnecessary, and three-digit counters look non-standard compared
to Kubernetes, Node.js, and Rust conventions.

**`alpha` instead of `dev`** — `alpha < beta < rc` sorts correctly as strings.
Rejected because the project stages are named dev/beta/rc/release and renaming
dev to alpha would introduce a mismatch between the tag and the pipeline
vocabulary.

**`sort -V` / `--sort=version:refname`** — both put bare `v0.1.0` before
`v0.1.0-dev.*` (since a string is a prefix of a longer string) and sort `beta`
before `dev`. Neither gives the correct cross-stage order for these names.

## Status

Status: Accepted

## Decision Makers

- Ernest Lee

## Tags

- release, versioning, git-tags, dev, beta, rc, 20260624-release-tag-progression-dev-beta-rc, madr-proposal-template

## Further Reading

```
@misc{semver2013,
  author = {Preston-Werner, Tom},
  title  = {Semantic Versioning 2.0.0},
  year   = {2013},
  url    = {https://semver.org/}
}

@misc{v_sekai_2026,
  title = {V-Sekai},
  year  = {2026},
  url   = {https://v-sekai.org/}
}
```
