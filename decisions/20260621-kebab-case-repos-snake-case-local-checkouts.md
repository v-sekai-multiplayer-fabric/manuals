---
title: GitHub repos use kebab-case; local checkout dirs keep build-native names
date: 2026-06-21
status: accepted
decision-makers: K. S. Ernest (iFire) Lee
tier: baseline
---

## Context and Problem Statement

Repositories across our orgs grew inconsistent names. The loot-action slice
under `v-sekai-multiplayer-fabric` mixed kebab-case (`combat-core`, `loot-core`)
with snake_case (`entity_packet`), and the `sinew-mocap` org carried
`mount_drift` and `vr_bridge` alongside kebab-case peers. We want one repo-naming
convention so clones, links, and code search stay predictable.

The complication is that several C++ repos are consumed as siblings _by directory
path_. `solve/CMakeLists.txt` does `add_subdirectory(../mount_drift …)`, CI
workflows in `solve`, `viewer`, and `packaging` check the repo out to
`path: mount_drift`, and the homebrew formula stages a `mount_drift` resource to
`../mount_drift`. Renaming the local checkout directory to kebab-case would break
every one of those hardcoded paths. So: what should repos be named, and must the
local checkout directory match the repo name?

## Decision Drivers

- Repo names should be uniform and discoverable across orgs.
- The convention must not break build wiring that hardcodes sibling directory paths.
- Language-native package identifiers (Lean, C++) are snake_case; local dirs that
  feed the build should respect that.
- Renaming a GitHub repo is low-risk: GitHub serves automatic redirects from the
  old name, so existing clone URLs and CI checkouts keep working.

## Considered Options

- Kebab-case everywhere — both GitHub repos and local checkout directories.
- snake_case everywhere.
- Kebab-case GitHub repos; local checkout directories keep build-native names.

## Decision Outcome

Chosen option: "Kebab-case GitHub repos; local checkout directories keep
build-native names", because it gives uniform remote naming while preserving the
directory names that CMake, CI, and packaging reference as siblings.

The rules:

- GitHub repository names are kebab-case, for example `combat-core`,
  `loot-core`, `entity-packet`, `mount-drift`, and `vr-bridge`.
- Local checkout directory names match what the build expects. Where a repo is
  consumed as a sibling by path (`add_subdirectory(../mount_drift)`, a CI
  `path:`, a homebrew `resource`), the local directory keeps the snake_case name
  the build hardcodes, so local `mount_drift` maps to remote
  `sinew-mocap/mount-drift`.
- Where no build path depends on the directory name, the local directory may
  match the kebab-case repo name. The loot-action slice directories were renamed
  to kebab-case on this basis (`combat-core`, `loot-core`, `entity-packet`, and
  the rest).
- Old remote URLs keep working through GitHub redirects. Update `origin` URLs at
  convenience, and leave the hardcoded `repository:` and `resource` strings that
  already resolve through the redirect.

### Consequences

- Good: remote names are uniform and code search / links are predictable.
- Good: a rename is just `gh repo rename` plus a local `git remote set-url`; CI
  that still clones the old name keeps working through the redirect.
- Good: no build breakage — sibling-by-path repos retain the directory name the
  build hardcodes.
- Bad: a local directory name can differ from its remote repo name
  (`mount_drift` ↔ `mount-drift`), which can surprise newcomers.
- Bad: fully propagating kebab-case into the build files (CMake, CI, homebrew)
  would require coordinated multi-repo PRs through the merge queue; that is
  deliberately out of scope here.

### Confirmation

- `gh repo list <org>` shows no repository name matching `[_A-Z]`.
- Repos consumed as siblings by path keep their snake_case checkout directory, and
  `add_subdirectory(../mount_drift)` still resolves locally.
- For `sinew-mocap`: `mount_drift` → `sinew-mocap/mount-drift` and `vr_bridge` →
  `sinew-mocap/vr-bridge` were renamed on GitHub; the local checkout directories
  remain `mount_drift` and `vr_bridge`.

## More Information

Relates to the org split that created `v-sekai-multiplayer-fabric` and to the
GHCR package-ownership decision; both concern how repositories are organized and
referenced. See `20260606-org-split-v-sekai-multiplayer-fabric` and
`20260506-ghcr-package-ownership-same-repo`.
