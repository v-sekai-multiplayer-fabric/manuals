---
title: Compiling the Godot engine
date: 2026-06-06
status: accepted
tier: baseline
---

## Context

Developers build the V-Sekai multiplayer-fabric Godot engine on two hosts from
one workstation: **Windows (PowerShell + MinGW)** and **WSL / Linux
(`linuxbsd`)**. Without a shared, persistent compiler cache, each host rebuilds
from scratch and cache hits are lost whenever a checkout is moved or renamed.

## Decision

Standardise on [`sccache`](https://github.com/mozilla/sccache) as the compiler
launcher plus SCons's own `CacheDir`, both pointed at one shared cache directory
reachable from both hosts. Wrap the build in a `gscons` shell function on each
host. Two environment variables parameterise the setup, so this guide hardcodes
no absolute paths:

- `GODOT_SRC` — the engine checkout root.
- `GODOT_BUILD_CACHE` — the shared cache directory.

### Prerequisites

| Tool     | Windows                       | WSL (Ubuntu 24.04)             |
| -------- | ----------------------------- | ------------------------------ |
| Python 3 | `scoop install python`        | system `python3`               |
| SCons    | `python -m pip install scons` | `python3 -m pip install scons` |
| Compiler | MinGW-w64 (`use_mingw=yes`)   | `build-essential` (gcc/g++)    |
| sccache  | `scoop install sccache`       | `brew install sccache`         |
| Git      | `scoop install git`           | system `git`                   |

Verify `sccache --version` resolves in each shell. The verified setup uses
**sccache 0.15.0**.

### Shared cache layout

Both the sccache object cache and the SCons `CacheDir` live under
`GODOT_BUILD_CACHE`:

| Purpose              | Path                             |
| -------------------- | -------------------------------- |
| sccache object cache | `$GODOT_BUILD_CACHE/sccache`     |
| SCons `CacheDir`     | `$GODOT_BUILD_CACHE/scons_cache` |

To share one store between Windows and WSL, set `GODOT_BUILD_CACHE` to a location
both can reach — on a combined workstation that is usually a drive WSL mounts
under `/mnt`. `sccache` keys include the compiler, target triple, and flags, so
MinGW and Linux objects coexist in the same store without colliding.

`SCCACHE_BASEDIRS` (the equivalent of ccache's `CCACHE_BASEDIR`) strips a leading
absolute prefix before hashing so hits survive a moved/renamed checkout. Point it
at `GODOT_SRC`. Paths must be **absolute**; separate multiple dirs with `;` on
Windows and `:` elsewhere (longest matching prefix wins). The server reads it at
startup — run `sccache --stop-server` after changing it.

### Windows — PowerShell profile

Set `GODOT_SRC` and `GODOT_BUILD_CACHE` to your locations, then add to
`Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1`:

```powershell
if (-not $env:GODOT_SRC) { $env:GODOT_SRC = "$env:USERPROFILE\godot" }
if (-not $env:GODOT_BUILD_CACHE) { $env:GODOT_BUILD_CACHE = "$env:LOCALAPPDATA\godot-build" }
$env:SCCACHE_DIR = "$env:GODOT_BUILD_CACHE\sccache"
$env:SCCACHE_CACHE_SIZE = "20G"
$env:SCCACHE_BASEDIRS = $env:GODOT_SRC
New-Item -ItemType Directory -Force -Path $env:SCCACHE_DIR, "$env:GODOT_BUILD_CACHE\scons_cache" | Out-Null
function gscons { python -m SCons platform=windows use_mingw=yes compiledb=yes target=editor precision=double c_compiler_launcher=sccache cpp_compiler_launcher=sccache "cache_path=$env:GODOT_BUILD_CACHE/scons_cache" -j16 @args }
```

### WSL / Linux — `~/.bashrc`

```bash
# Godot V-Sekai linuxbsd build. sccache caches object compilation.
export GODOT_SRC="${GODOT_SRC:-$HOME/godot}"                       # engine checkout
export GODOT_BUILD_CACHE="${GODOT_BUILD_CACHE:-$HOME/.cache/godot-build}"  # shared cache
export SCCACHE_DIR="${SCCACHE_DIR:-$GODOT_BUILD_CACHE/sccache}"
export SCCACHE_CACHE_SIZE="${SCCACHE_CACHE_SIZE:-20G}"
# Strip the checkout root from compile paths so cache hits survive a moved/renamed build dir.
export SCCACHE_BASEDIRS="${SCCACHE_BASEDIRS:-$GODOT_SRC}"
gscons() {
    python3 -m SCons compiledb=yes target=editor precision=double \
        c_compiler_launcher=sccache cpp_compiler_launcher=sccache \
        "cache_path=$GODOT_BUILD_CACHE/scons_cache" debug_symbols=yes tests=yes -j$(nproc) "$@"
}
```

Open a fresh shell (or `source ~/.bashrc` / `. $PROFILE`) so `gscons` is defined.

### Building

From your engine checkout (`$GODOT_SRC`):

```sh
gscons                      # full editor build
gscons verbose=yes          # extra args pass straight through to SCons
```

Output binary:

- Windows: `bin\godot.windows.editor.double.x86_64.exe`
- WSL: `bin/godot.linuxbsd.editor.double.x86_64`

The two functions differ only where the platform requires it: Windows pins
`platform=windows use_mingw=yes` and `-j16`; WSL infers `platform=linuxbsd`, uses
`-j$(nproc)`, and adds `debug_symbols=yes tests=yes`. Both share
`compiledb=yes target=editor precision=double` and the sccache launchers.

### Verifying and maintaining the cache

```sh
sccache --show-stats        # "Compile requests" / "Cache hits" climb across builds
sccache --stop-server       # apply changed SCCACHE_* env vars
sccache --zero-stats        # reset counters
```

A clean first build is mostly misses; a second build of the same tree shows a high
hit rate and finishes substantially faster. The store is capped at
`SCCACHE_CACHE_SIZE` (20G) and evicts least-recently-used entries automatically.

## Consequences

- One cache directory (`GODOT_BUILD_CACHE`) serves both hosts; management is a
  single location.
- The engine `SConstruct` recognises only `cache_path` and `cache_limit` for the
  SCons cache. `scons_cache=` is **not** valid and is silently ignored.
- If the shared cache lives on a Windows drive mounted into WSL, that mount is
  slower than native ext4 — the trade-off accepted for sharing one store.
- Common failures: no hits between builds → server started before the env vars,
  run `sccache --stop-server`; no hits after relocating a checkout → set
  `SCCACHE_BASEDIRS` to the checkout root.

## Further reading

- [sccache local cache (`SCCACHE_DIR`, `SCCACHE_CACHE_SIZE`)](https://github.com/mozilla/sccache/blob/main/docs/Local.md)
- [sccache configuration (`SCCACHE_BASEDIRS`)](https://github.com/mozilla/sccache/blob/main/docs/Configuration.md)
- [Godot `SConstruct`](https://github.com/godotengine/godot/blob/master/SConstruct)
