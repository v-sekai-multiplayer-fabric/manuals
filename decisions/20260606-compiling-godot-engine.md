---
title: Compiling the Godot engine
date: 2026-06-06
status: accepted
---

## Context

Developers build the V-Sekai multiplayer-fabric Godot engine on two hosts from
one workstation: **Windows (PowerShell + MinGW)** and **WSL / Linux
(`linuxbsd`)**. Without a shared, persistent compiler cache, each host rebuilds
from scratch and cache hits are lost whenever a checkout is moved or renamed.

## Decision

Standardise on [`sccache`](https://github.com/mozilla/sccache) as the compiler
launcher plus SCons's own `CacheDir`, both pointed at a single physical directory
on the `E:` drive so Windows and WSL share one store. Wrap the build in a
`gscons` shell function on each host.

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

WSL mounts `E:` at `/mnt/e`, so the same files back both build hosts:

| Purpose              | Windows path                       | WSL path                               |
| -------------------- | ---------------------------------- | -------------------------------------- |
| sccache object cache | `E:\godot-build-cache\sccache`     | `/mnt/e/godot-build-cache/sccache`     |
| SCons `CacheDir`     | `E:\godot-build-cache\scons_cache` | `/mnt/e/godot-build-cache/scons_cache` |

`sccache` keys include the compiler, target triple, and flags, so MinGW and Linux
objects coexist in the same store without colliding — they simply do not hit each
other. Sharing the location keeps cache management to one directory.

`SCCACHE_BASEDIRS` (the equivalent of ccache's `CCACHE_BASEDIR`) strips a leading
absolute prefix before hashing so hits survive a moved/renamed checkout. Set it to
the checkout root. Paths must be **absolute**; separate multiple dirs with `;` on
Windows and `:` elsewhere (longest matching prefix wins). The server reads it at
startup — run `sccache --stop-server` after changing it.

### Windows — PowerShell profile

Add to `Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1`:

```powershell
# Shared build cache on E: — same physical dir as WSL (/mnt/e/godot-build-cache).
$env:SCCACHE_DIR = "E:\godot-build-cache\sccache"
$env:SCCACHE_CACHE_SIZE = "20G"
# Strip the checkout root from compile paths so cache hits survive a moved/renamed build dir.
$env:SCCACHE_BASEDIRS = "E:\godot"
New-Item -ItemType Directory -Force -Path $env:SCCACHE_DIR, "E:\godot-build-cache\scons_cache" | Out-Null
function gscons { python -m SCons platform=windows use_mingw=yes compiledb=yes target=editor precision=double c_compiler_launcher=sccache cpp_compiler_launcher=sccache cache_path=E:/godot-build-cache/scons_cache -j16 @args }
```

### WSL / Linux — `~/.bashrc`

```bash
# Godot V-Sekai linuxbsd build.
# Uses sccache as the compiler launcher to cache object compilation.
export SCCACHE_DIR="${SCCACHE_DIR:-/mnt/e/godot-build-cache/sccache}"
export SCCACHE_CACHE_SIZE="${SCCACHE_CACHE_SIZE:-20G}"
# Strip the checkout root from compile paths so cache hits survive a moved/renamed build dir.
export SCCACHE_BASEDIRS="${SCCACHE_BASEDIRS:-/mnt/e/godot}"
gscons() {
    python3 -m SCons compiledb=yes target=editor precision=double \
        c_compiler_launcher=sccache cpp_compiler_launcher=sccache \
        cache_path=/mnt/e/godot-build-cache/scons_cache debug_symbols=yes tests=yes -j$(nproc) "$@"
}
```

Open a fresh shell (or `source ~/.bashrc` / `. $PROFILE`) so `gscons` is defined.

### Building

From the engine checkout (`E:\godot` / `/mnt/e/godot`):

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

- One cache directory on `E:` serves both hosts; management is a single location.
- The engine `SConstruct` recognises only `cache_path` and `cache_limit` for the
  SCons cache. `scons_cache=` is **not** valid and is silently ignored.
- WSL builds run against `/mnt/e`, whose 9p mount is slower than native ext4 —
  the trade-off accepted for a shared cache.
- Common failures: no hits between builds → server started before the env vars,
  run `sccache --stop-server`; no hits after relocating a checkout → set
  `SCCACHE_BASEDIRS` to the checkout root.

## Further reading

- [sccache local cache (`SCCACHE_DIR`, `SCCACHE_CACHE_SIZE`)](https://github.com/mozilla/sccache/blob/main/docs/Local.md)
- [sccache configuration (`SCCACHE_BASEDIRS`)](https://github.com/mozilla/sccache/blob/main/docs/Configuration.md)
- [Godot `SConstruct`](https://github.com/godotengine/godot/blob/master/SConstruct)
