---
title: Compiling the Godot engine
date: 2026-06-06
status: accepted
decision-makers: K. S. Ernest (iFire) Lee
tier: baseline
---

## Context

Developers build the V-Sekai multiplayer-fabric Godot engine on two hosts from
one workstation: **Windows (PowerShell + MinGW)** and **WSL / Linux
(`linuxbsd`)**. Without a shared, persistent compiler cache, each host rebuilds
from scratch and cache hits are lost whenever a checkout is moved or renamed.

## Decision

Standardise on [`sccache`](https://github.com/mozilla/sccache) as the **only**
object cache, wired in as the SCons compiler launcher. Wrap the build in a
`gscons` shell function on each host.

**Do not also enable SCons's own `CacheDir`** (`cache_path=`). sccache already
caches every compiled object before SCons's cache would see it, so running both
double-caches the same artefacts — wasted disk and I/O for no extra hits. sccache
is the single source of truth.

Cross-host sharing is handled by sccache's **S3-compatible storage backend**, not
by a shared filesystem directory. Credentials come from a local AWS profile
(`~/.aws/credentials`) and are **never committed** — only the non-secret bucket
coordinates are configured, via environment variables, so this guide hardcodes no
absolute paths and no secrets:

- `GODOT_SRC` — the engine checkout root.
- `SCCACHE_BUCKET` / `SCCACHE_ENDPOINT` / `SCCACHE_REGION` — your S3 bucket
  coordinates.
- `AWS_PROFILE` — the named profile holding the access keys, read from
  `~/.aws/credentials`. The keys themselves stay on the developer's machine.

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

### Storage backend

sccache picks its backend from environment variables. Two options:

- To share the cache across hosts (recommended), use an S3-compatible bucket: set
  the `SCCACHE_BUCKET` / `SCCACHE_ENDPOINT` / `SCCACHE_REGION` coordinates and point
  `AWS_PROFILE` at a profile in `~/.aws/credentials`. sccache keys include the
  compiler, target triple, and flags, so Windows/MinGW and Linux objects coexist
  in one bucket without colliding. A `SCCACHE_S3_KEY_PREFIX` namespaces these
  objects so they never collide with other projects sharing the bucket.
- For a single host, use a local directory instead: set `SCCACHE_DIR` and
  `SCCACHE_CACHE_SIZE`, and sccache uses local disk with no S3 config needed.

> **Secrets policy:** only the bucket _name, endpoint, region, and key prefix_ —
> none of which are secrets — appear in committed config. The access key and
> secret are never committed to any repo, dotfile, or build log. They live in one
> of two places depending on where the build runs:
>
> - **Locally:** `~/.aws/credentials` under a named profile (`AWS_PROFILE`).
> - **CI:** GitHub Actions **secret variables**, injected at runtime via the
>   `${{ secrets.* }}` context. Storing the keys there is fine — they are
>   encrypted and never land in the repo. What is _not_ fine is pasting a literal
>   key into a workflow YAML, a script, or this manual.

### CI — GitHub Actions

In a workflow, read the credentials from secret variables into the sccache S3
environment for the build step. Only the secret _names_ appear in the committed
YAML — the values are stored in the repo/org Actions secrets:

```yaml
env:
  SCCACHE_BUCKET: <your-sccache-bucket> # non-secret coordinates
  SCCACHE_ENDPOINT: <region>.example-object-store.com
  SCCACHE_REGION: <region>
  SCCACHE_S3_KEY_PREFIX: godot
  AWS_ACCESS_KEY_ID: ${{ secrets.SCCACHE_AWS_ACCESS_KEY_ID }} # from Actions secrets
  AWS_SECRET_ACCESS_KEY: ${{ secrets.SCCACHE_AWS_SECRET_ACCESS_KEY }}
```

sccache reads `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` directly, so CI needs
no `~/.aws/credentials` file or `AWS_PROFILE`.

`SCCACHE_BASEDIRS` (the equivalent of ccache's `CCACHE_BASEDIR`) strips a leading
absolute prefix before hashing so hits survive a moved/renamed checkout. Point it
at `GODOT_SRC`. Paths must be **absolute**; separate multiple dirs with `;` on
Windows and `:` elsewhere (longest matching prefix wins). The server reads it at
startup — run `sccache --stop-server` after changing it.

### Windows — PowerShell profile

Set `GODOT_SRC` and the S3 coordinates to your values, then add to
`Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1`. The function sets
the sccache env only for the duration of the build and restores it afterwards, so
the interactive session and the real AWS CLI are never shadowed:

```powershell
if (-not $env:GODOT_SRC) { $env:GODOT_SRC = "$env:USERPROFILE\godot" }
function gscons {
    $envset = [ordered]@{
        SCCACHE_BUCKET        = '<your-sccache-bucket>'
        SCCACHE_ENDPOINT      = '<region>.example-object-store.com'
        SCCACHE_REGION        = '<region>'
        SCCACHE_S3_USE_SSL    = 'true'
        SCCACHE_S3_KEY_PREFIX = 'godot'
        SCCACHE_BASEDIRS      = $env:GODOT_SRC
        AWS_PROFILE           = '<your-s3-profile>'   # keys live in ~/.aws/credentials, never committed
    }
    $saved = @{}
    foreach ($k in $envset.Keys) { $saved[$k] = [Environment]::GetEnvironmentVariable($k, 'Process'); Set-Item "env:$k" $envset[$k] }
    try {
        python -m SCons platform=windows use_mingw=yes compiledb=yes target=editor precision=double `
            c_compiler_launcher=sccache cpp_compiler_launcher=sccache -j16 @args
    } finally {
        foreach ($k in $envset.Keys) { if ($null -eq $saved[$k]) { Remove-Item "env:$k" -ErrorAction SilentlyContinue } else { Set-Item "env:$k" $saved[$k] } }
    }
}
```

### WSL / Linux — `~/.bashrc`

```bash
# Godot V-Sekai linuxbsd build. sccache is the only object cache; S3 backend shares it across hosts.
export GODOT_SRC="${GODOT_SRC:-$HOME/godot}"                 # engine checkout
export SCCACHE_BUCKET="${SCCACHE_BUCKET:-<your-sccache-bucket>}"
export SCCACHE_ENDPOINT="${SCCACHE_ENDPOINT:-<region>.example-object-store.com}"
export SCCACHE_REGION="${SCCACHE_REGION:-<region>}"
export SCCACHE_S3_USE_SSL="${SCCACHE_S3_USE_SSL:-true}"
export SCCACHE_S3_KEY_PREFIX="${SCCACHE_S3_KEY_PREFIX:-godot}"
export AWS_PROFILE="${AWS_PROFILE:-<your-s3-profile>}"       # keys in ~/.aws/credentials, never committed
# Strip the checkout root from compile paths so cache hits survive a moved/renamed build dir.
export SCCACHE_BASEDIRS="${SCCACHE_BASEDIRS:-$GODOT_SRC}"
gscons() {
    python3 -m SCons compiledb=yes target=editor precision=double \
        c_compiler_launcher=sccache cpp_compiler_launcher=sccache \
        debug_symbols=yes tests=yes -j$(nproc) "$@"
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
`compiledb=yes target=editor precision=double` and the sccache launchers — and
**neither** enables a SCons `CacheDir`.

### Verifying and maintaining the cache

```sh
sccache --show-stats        # "Compile requests" / "Cache hits" climb across builds
sccache --stop-server       # apply changed SCCACHE_* / AWS_PROFILE env vars
sccache --zero-stats        # reset counters
```

A clean first build is mostly misses; a second build of the same tree shows a high
hit rate and finishes substantially faster. With the S3 backend, a build on the
_other_ host hits the same objects once they are uploaded.

## Consequences

- There is one object cache, not two: sccache is the sole cache; the SCons
  `CacheDir` is deliberately not enabled, so the same objects are never stored twice.
- One S3 bucket serves both hosts; management is a single location, and a checkout
  can move or be renamed without losing hits (`SCCACHE_BASEDIRS`).
- No secrets live in the repo; bucket coordinates are non-secret config. Access
  keys live in `~/.aws/credentials` locally and in GitHub Actions secret
  variables in CI, never in committed files or build logs.
- The engine `SConstruct` recognises only `cache_path` and `cache_limit` for the
  SCons cache. We intentionally pass neither. `scons_cache=` is **not** valid and
  is silently ignored.
- Common failures: no hits between builds → server started before the env vars,
  run `sccache --stop-server`; no hits after relocating a checkout → set
  `SCCACHE_BASEDIRS` to the checkout root; S3 auth errors → wrong/expired
  `AWS_PROFILE` or missing `~/.aws/credentials` entry.

## Further reading

- [sccache S3 storage (`SCCACHE_BUCKET`, `SCCACHE_ENDPOINT`, `SCCACHE_S3_KEY_PREFIX`)](https://github.com/mozilla/sccache/blob/main/docs/S3.md)
- [sccache configuration (`SCCACHE_BASEDIRS`)](https://github.com/mozilla/sccache/blob/main/docs/Configuration.md)
- [Godot `SConstruct`](https://github.com/godotengine/godot/blob/master/SConstruct)
