---
title: Fly.io for deployment
date: 2026-05-01
status: superseded by 20260606-self-host-on-harvester-hci.md
tier: baseline
---

## Context

The stack requires a platform that supports UDP (for QUIC/WebTransport), private networking between services, persistent volumes, and on-demand machines for job workloads (asset baking).

## Decision

Deploy all services on Fly.io in the `iad` (Ashburn, Virginia) region.

- Machines handle deployment; Terraform (fly-apps/fly provider v0.0.21) manages resources (apps, IPs, volumes, secrets) but not machines, due to Machines API limitations in the provider.
- Private networking uses Fly's 6PN (WireGuard mesh). All `.internal` DNS resolves to IPv6 only, requiring `socket_options: [:inet6]` in any Erlang/Elixir TCP stack.
- Dedicated IPv4 is required for UDP. Fly passes UDP without DNAT; the app must bind to the same port clients connect to.
- On-demand machines (Fly Machines API) are used for the baker — one machine per bake job, exits when done.

## Consequences

- All services must be in the same region to communicate over the private network without egress charges.
- `.flycast` requires `[[services]]` on the target app; `.internal` works without it.
- Cloudflare proxy must be disabled for UDP/QUIC endpoints; DNS-only records point directly to the Fly IP.
- Terraform state is stored on a `tfstate` orphan branch in the infra repo to avoid requiring a remote backend.
