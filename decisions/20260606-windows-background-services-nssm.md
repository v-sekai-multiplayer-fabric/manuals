---
title: Running background services on Windows with nssm
date: 2026-06-06
status: accepted
tier: baseline
deciders: K. S. Ernest (iFire) Lee
---

## Context and Problem Statement

Several pieces of the workstation stack need to run as long-lived background
processes that survive shells, log-offs, and reboots, and restart themselves when
they crash:

- the [sccache](https://github.com/mozilla/sccache) compile-cache server(s)
  backing native builds,
- Godot dedicated/headless game servers,
- a CockroachDB (`crdb`) node for the local RDBMS,
- zone servers and similar per-world daemons.

The naive approaches all failed in practice. Starting these by hand in a terminal
ties them to that shell. The compile cache made the problem concrete: sccache
auto-starts a single machine-wide server on first use, and whichever project
touches it first fixes its configuration (S3 key prefix, base dirs) for everyone —
so a second project silently inherits the wrong cache namespace. Worse, a
configuration that lives only in a per-build environment forces a
stop/start of the server on every build to apply it, which is slow and races
("Address in use"). None of this is "a service" in the Windows sense: nothing owns
the process lifecycle.

We are not local administrators by default, and Windows `sudo` here runs in
_Force New Window_ mode, so any elevation is an interactive UAC prompt.

## Decision Drivers

- Processes must auto-start at boot and auto-restart on crash, independent of any
  interactive session.
- Multiple instances of the same program must coexist without clobbering each
  other's state (e.g. one cache server per project, several game/zone servers).
- Secrets (object-store keys, DB credentials) must never be written into a repo,
  a service definition, or the registry — only read at runtime from their existing
  secured location.
- The target programs are plain executables, not native Windows services, so they
  do not implement the Service Control Manager (SCM) protocol on their own.
- Setup must be reproducible from a script and reviewable after an elevated run.

## Considered Options

- **Run by hand in a terminal** — dies with the shell; no restart; no boot start.
- **Scheduled Task (logon trigger)** — runs in the user session and needs no
  service wrapper, but it is not a true service (no SCM state, weaker restart
  semantics), and registering one was denied by policy on this machine.
- **`sc.exe create` directly** — the SCM expects a process that implements the
  service protocol; a bare exe started this way is killed as non-responsive.
- **[nssm](https://nssm.cc/) (Non-Sucking Service Manager) wrapping the program**
  — a thin supervisor that _is_ a proper service and keeps an ordinary foreground
  process alive, restarting it on exit.

## Decision Outcome

Chosen option: **nssm-supervised foreground processes, one Windows service per
instance.** nssm satisfies the SCM, so each target runs as a real
auto-start/auto-restart service while staying an ordinary executable.

The pattern has four parts:

1. **Run the target in the foreground** — a supervisor can only watch a process
   that does not fork-and-exit. For sccache that means
   `SCCACHE_START_SERVER=1` + `SCCACHE_NO_DAEMON=1` and invoking the bare binary
   (not `--start-server`, which always daemonizes). Most servers (Godot
   `--headless`, `cockroach start`, zone daemons) are already foreground.

2. **A per-instance launcher script** sets that instance's environment and execs
   the program by **absolute path** — services run as _LocalSystem_, whose `PATH`
   does not include user shims (e.g. scoop). Secrets are read at runtime from
   their existing secured file (for sccache, the object-store keys come from the
   `do-tor1` AWS profile in `~/.aws/credentials`, exported as
   `AWS_ACCESS_KEY_ID`/`AWS_SECRET_ACCESS_KEY` because sccache's S3 backend
   ignores AWS _profiles_). Nothing secret is written to disk by the script.

3. **An elevated installer script** registers each service with nssm, sets it to
   `SERVICE_AUTO_START`, enables restart-on-exit with a throttle/delay, points
   stdout/stderr at rotating log files, and starts it. It is idempotent
   (stop + remove + reinstall) and writes a transcript so the result can be
   reviewed after the separate elevated window closes.

4. **Instance isolation by port (and namespace)** — each instance listens on its
   own loopback port; clients select an instance by port. Loopback is not
   session-isolated, so a LocalSystem service in session 0 is reachable from the
   user session. sccache additionally uses a distinct S3 key prefix per instance.

### Worked example — the sccache services

Two services back two projects from the one shared object-store bucket, kept apart
by port and key prefix:

| Service             | Port | Key prefix  | Base dirs (checkout roots)     |
| ------------------- | ---- | ----------- | ------------------------------ |
| `sccache-godot`     | 4227 | `godot`     | the Godot checkout + merge dir |
| `sccache-idtx-flow` | 4226 | `idtx-flow` | the idtx-flow checkouts        |

4226 is sccache's default port, so the idtx-flow builds use that service with no
changes; the Godot build sets `SCCACHE_SERVER_PORT=4227`. The build wrapper
(`gscons`) therefore no longer manages the server at all — it sets one port
variable and runs. This supersedes the earlier per-build environment juggling and
server restarts described in
[Compiling the Godot engine](20260606-compiling-godot-engine.md) and
[Checking the sccache build cache](20260606-checking-sccache.md).

### Applying the pattern elsewhere

The same launcher + installer shape runs other dev infrastructure as services:

- **Godot dedicated servers** — one service per instance, each on its own port;
  the launcher passes `--headless` and the scene/port arguments.
- **Zone servers** — one service per zone/world, isolated by port, supervised and
  restarted independently so one zone crashing does not take down the others.
- **Zone backends** — the per-zone backend daemons (state/persistence/matchmaking
  workers) behind those zone servers, each its own service with its own port and
  runtime-read credentials.
- **CockroachDB** — a `cockroach start` (or `start-single-node`) service; secrets
  (certs/join tokens) read at runtime, data dir as an absolute path.

### Consequences

- Good: real services — boot start, crash restart, and lifecycle owned by the SCM,
  not a terminal.
- Good: many instances of one binary coexist cleanly (port/namespace per service).
- Good: no secrets in the repo, the service config, or the registry; they stay in
  their existing secured files and are read at runtime.
- Good: build/runtime wrappers shrink to "pick a port and run" — no server
  management, no restart races.
- Bad: requires one-time elevation per install/change; with _Force New Window_
  sudo this is an interactive UAC prompt and the output must be logged to a file
  to be reviewed afterward.
- Bad: services run as LocalSystem in session 0, so launchers must use absolute
  paths and cannot rely on the user environment; anything needing the desktop is
  unsuitable.
- Bad: nssm is an extra dependency to install (via scoop) and keep updated.

### Confirmation

After install, both sccache services report `Running` with `Automatic` start, and
`sccache --show-stats` on each port shows the expected S3 backend
(`s3, name: <bucket>`) with the correct per-project key prefix and base dirs — so
isolation, credentials, and auto-start all hold. A subsequent build connects on
port 4227 and accumulates cache hits with zero cache errors.

## More Information

- Foreground is the crux: a fork-and-exit daemon makes nssm see an immediate exit
  and enter its rapid-exit guard (`SERVICE_PAUSED`). Verify a target stays in the
  foreground before wrapping it.
- LocalSystem can read another user's secured files (e.g. the AWS credentials
  file), but `$HOME`/`%USERPROFILE%` resolve to the system profile — always pass
  absolute paths to both the launcher and the secrets it reads.
- Restart-on-crash plus a throttle/delay avoids a hot loop when a target is
  misconfigured; check the per-service stderr log to diagnose.
- Related: [Compiling the Godot engine](20260606-compiling-godot-engine.md),
  [Checking the sccache build cache](20260606-checking-sccache.md).
