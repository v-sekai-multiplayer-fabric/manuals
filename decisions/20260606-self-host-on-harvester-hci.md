---
title: Self-host on Harvester HCI instead of Fly.io
date: 2026-06-06
status: superseded by 20260613-quadlets-on-fedora-44-instead-of-harvester.md
tier: baseline
supersedes: 20260501-fly-io-for-deployment.md, 20260506-maglev-cycle-0-infra.md
---

## Context and Problem Statement

The runtime first deployed on Fly.io (see the superseded Fly.io decision and Maglev
Cycle 0). The project is moving to a self-hosted Harvester HCI cluster, where each
service runs as a qcow2 VM image driven by podman quadlets. This records that
Fly.io is no longer the deployment target.

## Decision Drivers

- Own the cluster, its cost, and its control.
- Ship each service as a VM image run by podman quadlets.
- Reuse the existing image build pipeline.

## Considered Options

- Stay on Fly.io.
- Self-host on Harvester HCI.

## Decision Outcome

Chosen option: "Self-host on Harvester HCI". Fly.io is no longer used. Deployment
is OpenTofu in [infra](https://github.com/v-sekai-multiplayer-fabric/infra) onto a
Harvester cluster, with each service a qcow2 image (`linux-base-image` plus the
per-service `*-image` repos) run as a podman quadlet.

This supersedes [Fly.io for deployment](20260501-fly-io-for-deployment.md) and
[Maglev Cycle 0: Terraform Fly.io Infrastructure](20260506-maglev-cycle-0-infra.md).

### Consequences

- Good: full control of the cluster, and the VM-image pipeline already exists.
- Bad: we operate our own HCI cluster.
- Bad: the migration is mid-pivot (see the infra repo's `docs/migration-status.md`),
  so some older records still mention Fly until each service moves.

### Confirmation

The infra repo provisions Harvester VMs via OpenTofu and podman quadlets, and
creates no Fly.io resources.

## More Information

The VM images live in the `*-image` repos; the engine is
[pinned to a frozen Godot 4.7 commit](20260606-pin-engine-to-frozen-godot-4-7.md).
