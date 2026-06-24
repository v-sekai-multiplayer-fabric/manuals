---
title: Checking the sccache build cache
date: 2026-06-06
status: accepted
decision-makers: K. S. Ernest (iFire) Lee
tier: baseline
---

## Context and Problem Statement

Native builds route compilation through [sccache](https://github.com/mozilla/sccache)
backed by a shared DigitalOcean Spaces bucket (`chibifire-sccache`, region `tor1`),
so object files are cached across machines and CI (see
[Compiling the Godot engine](20260606-compiling-godot-engine.md)). The failure mode
is silent: if the `SCCACHE_*` environment is missing, the credentials are wrong, or
the region/endpoint is off, sccache quietly falls back to a local disk cache — or
records read/write errors — while the build still succeeds. The shared-cache benefit
is lost with no obvious signal. How does someone confirm sccache is actually using
the remote bucket and is healthy?

## Decision Drivers

- A misconfigured cache degrades silently (local disk, or errored requests) without
  failing the build, so "the build worked" is not evidence the cache worked.
- The check should be one command, not a ritual or a log dive.
- Credentials are scoped to the `do-tor1` AWS profile, not global environment
  variables, so the check must not require exporting secrets.
- It should read the same on Windows (PowerShell) and WSL/Linux.

## Considered Options

- Infer from build times (implicit, unreliable, no backend visibility).
- Enable `SCCACHE_LOG=debug` and read the per-request log every build.
- Read `sccache --show-stats` and check the backend and error counters.

## Decision Outcome

Chosen option: "Read `sccache --show-stats`", because it surfaces the cache backend
and health in one command without secrets or log parsing.

Check three lines of the output:

- `Cache location` must be `s3, name: chibifire-sccache` (with the project's key
  prefix, e.g. `/godot/`). If it says `Local disk`, the `SCCACHE_*` env vars are
  not set in that shell and the shared cache is not in use.
- `Cache errors` (and read/write errors) must be `0`. Non-zero means a
  credentials, endpoint, or connectivity problem.
- `Cache hits` versus `Cache misses` are the payoff; the hit rate rises across
  builds.

On Windows this is wrapped as a `sccheck` PowerShell function (alias `scc`) in the
user profile; aliases cannot carry logic, hence a function plus a `Set-Alias` shim:

```powershell
function sccheck {
    sccache --show-stats |
        Select-String -Pattern 'Compile requests|Cache hits|Cache misses|Cache .*errors|Cache location'
}
Set-Alias scc sccheck
```

The bash equivalent is `sccache --show-stats` filtered with `grep`. To measure a
single build, reset first: `sccache --zero-stats; <build>; sccache --show-stats`.

### Consequences

- Good: one command shows the backend and health; no secrets needed, since stats
  read the running server's own counters.
- Good: works identically across shells; the PowerShell `sccheck`/`scc` shortcut
  makes it a reflex.
- Bad: the counters are per-server-session — they reset when the sccache server
  restarts or on `--zero-stats`, so they are not lifetime bucket totals.
- Bad: `--show-stats` alone does not prove S3 connectivity; only a compile (or a
  full build) exercises read/write. `Cache errors = 0` _after_ a build is the real
  confirmation that auth and the endpoint are correct.

### Confirmation

Running `sccheck` reported `Cache location  s3, name: chibifire-sccache, prefix:
/godot/`, `Cache errors 0`, and hits accumulating during a Godot rebuild — so the
remote backend, region, and `do-tor1` credentials are all working.

## More Information

- The non-secret `SCCACHE_*` variables (`SCCACHE_BUCKET`, `SCCACHE_ENDPOINT`,
  `SCCACHE_REGION`, `SCCACHE_S3_USE_SSL`, `SCCACHE_S3_KEY_PREFIX`) are set globally;
  credentials live in the `do-tor1` profile (`~/.aws/credentials`) and are applied
  only for the duration of a build, so the real AWS CLI is never shadowed.
- Per-project key prefixes keep objects from colliding in the one bucket (e.g.
  `godot` vs `idtx-flow`).
- To debug a non-zero error count, set `SCCACHE_LOG=debug` and `SCCACHE_ERROR_LOG`
  before restarting the server (`sccache --stop-server; sccache --start-server`).
