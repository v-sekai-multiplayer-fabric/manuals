---
title: Install organization Blender add-ons under /opt/org.v-sekai via BLENDER_SYSTEM_SCRIPTS, outside home and the package tree
date: 2026-06-14
status: proposed
---

## Context and Problem Statement

Blender add-ons drive parts of the asset pipeline — the blender-mcp runtime bridge plus
its NodeOSC dependency
([v2.0.0-dev.1](https://github.com/v-sekai-multiplayer-fabric/blender-mcp/releases/tag/v2.0.0-dev.1)),
and the V-Sekai game tools among them. These are organization add-ons that belong on the
machine for every artist and every headless run, so the install target is an OS-level
question rather than a per-user one. Blender offers two default targets and both are a
poor home for shared add-ons: the per-user path `~/.config/blender/<ver>/scripts/addons`
(and the Windows and macOS equivalents) lives under a home directory, and the bundled
system path `/usr/share/blender/<ver>/scripts` is owned by the installing package
manager. On this host Blender is the Fedora rpm `blender-5.1.1-3.fc44`, with
`system_resource('SCRIPTS')` at `/usr/share/blender/5.1/scripts`; a Homebrew or tarball
install puts that same path somewhere else again. This records where organization Blender
add-ons go.

## Decision Drivers

- The add-ons load for every user on the machine and in headless runs, so the location
  sits outside any one home directory.
- A Blender upgrade through `dnf`, Homebrew, or a tarball must leave the add-ons in
  place, so the location sits outside the package-owned Blender tree that an upgrade
  overwrites.
- The same install procedure holds however Blender was installed, so the location is
  decoupled from where the Blender binary lands.
- The directory name carries the organization identity so it stays clear of other
  vendors' `/opt` entries, which the reverse-DNS form `org.v-sekai` (from
  [v-sekai.org](https://v-sekai.org/), the Java package and macOS bundle-id convention)
  supplies.
- No hardcoded absolute home paths, per the manuals path convention.

## Considered Options

- Per-user OS default path (`~/.config/blender/<ver>/scripts/addons` and the Windows and
  macOS equivalents).
- Blender's bundled system scripts directory
  (`/usr/share/blender/<ver>/scripts/addons`, or the Homebrew Cellar / app-bundle
  equivalent).
- A stable organization directory under `/opt`, added to Blender's search paths through
  `BLENDER_SYSTEM_SCRIPTS`.

## Decision Outcome

Chosen option: "a stable organization directory under `/opt`, added to Blender's search
paths through `BLENDER_SYSTEM_SCRIPTS`", because it gives one OS-level, package-manager
independent home for shared add-ons that survives a Blender upgrade and stays out of
every user's home directory.

We do not install into Blender's own OS path
(`/usr/share/blender/<ver>/scripts/addons`): it needs root, a `dnf` or Homebrew Blender
upgrade replaces the whole tree and wipes anything dropped there, and the path is pinned
to the Blender version and the install method. We instead create an org directory that
the package manager never touches and point Blender at it:

```sh
# created once on the machine, owned by the org group; FHS /opt for add-on software,
# namespaced reverse-DNS as org.v-sekai (from v-sekai.org) to avoid /opt collisions
#   /opt/org.v-sekai/blender/scripts/
#   /opt/org.v-sekai/blender/scripts/addons/        <- add-ons land here
#   /opt/org.v-sekai/blender/scripts/addons/NodeOSC/      (folder)
#   /opt/org.v-sekai/blender/scripts/addons/blender_mcp/  (addon + server, from the release)

# set machine-wide so every launch sees it (e.g. /etc/profile.d/ or the launcher)
export BLENDER_SYSTEM_SCRIPTS="/opt/org.v-sekai/blender/scripts"
```

`BLENDER_SYSTEM_SCRIPTS` adds the directory to Blender's search paths rather than
replacing the bundle. A probe on this host confirmed it: with the variable set,
`bpy.utils.script_paths()` lists the bundled `/usr/share/blender/5.1/scripts`, the user
path, and the org path together; an add-on dropped in the org `addons/` is discovered;
and `system_resource('SCRIPTS')` still resolves to the bundled tree, so the bundled core
add-ons keep loading. The org directory survives Blender reinstalls because the package
manager owns only `/usr/share/blender/<ver>` and `/opt/org.v-sekai` sits outside it.

This answers where blender-mcp v2.0.0-dev.1 and NodeOSC go: into
`/opt/org.v-sekai/blender/scripts/addons/`, away from any home directory and away from the
package-owned Blender tree.

### Consequences

- Good: shared add-ons load for every user and every headless run from one OS-level path.
- Good: a Blender upgrade through `dnf`, Homebrew, or a tarball leaves the add-ons in
  place, since the package manager never writes to `/opt/org.v-sekai`.
- Good: one environment variable points Blender at the directory however the binary was
  installed, so the procedure holds across machines and install methods.
- Bad: someone creates `/opt/org.v-sekai` once with org-group ownership, and a machine that
  skips setting `BLENDER_SYSTEM_SCRIPTS` falls back to the home and bundle paths.
- Bad: a Blender major upgrade can break a legacy add-on's API, so the contents of the
  directory are re-pinned per major version even though the path is stable.

### Confirmation

With `BLENDER_SYSTEM_SCRIPTS=/opt/org.v-sekai/blender/scripts` exported, `blender --background
--python-expr "import bpy; print(bpy.utils.script_paths())"` lists the org path, and
`blender --command extension list` (or the add-on preferences) shows blender-mcp and
NodeOSC loading from it. `bpy.utils.system_resource('SCRIPTS')` still reports the bundled
tree, confirming the bundle is intact. A `dnf reinstall blender` leaves
`/opt/org.v-sekai/blender/scripts/addons/` untouched.

## More Information

The blender-mcp bridge pairs with the
[MCP runtime bridge for deployed builds](20260612-mcp-runtime-bridge-deployed-builds.md).
NodeOSC installs as a folder under the same `addons/` directory, and the blender-mcp
add-on and its server install together from the fabric release.
