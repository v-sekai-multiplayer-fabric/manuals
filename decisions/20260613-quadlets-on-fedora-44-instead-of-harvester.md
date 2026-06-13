---
title: Run services as systemd podman quadlets on Fedora 44 instead of Harvester HCI
date: 2026-06-13
status: accepted
tier: baseline
supersedes: 20260606-self-host-on-harvester-hci.md
---

## Context and Problem Statement

The superseded Harvester decision ships each service as a qcow2 VM image on a
Harvester HCI cluster, with podman quadlets running inside each VM. The quadlets
already drive the workloads; the Harvester layer wraps a full virtualization tier —
hypervisor, VM lifecycle, qcow2 pipeline — around the container runtime the services
depend on. Fedora 44 runs podman quadlets under systemd directly on the host. This
records that Harvester HCI is not the deployment target.

## Decision Drivers

- Quadlets drive the workloads, so the host runs them directly and the VM tier carries
  no load the containers need.
- Stock tooling — Fedora 44, systemd, podman — carries the runtime in place of a
  bespoke HCI stack.
- An OCI container image is the deploy artifact, so the build skips the qcow2 VM step.
- No hypervisor or cluster control plane sits under the services.
- Self-hosting keeps ownership of the hosts, their cost, and their control.

## Considered Options

- Keep Harvester HCI, with qcow2 VMs running quadlets inside.
- Run podman quadlets directly on Fedora 44 hosts under systemd.
- Return to a managed PaaS.

## Decision Outcome

Chosen option: "run podman quadlets directly on Fedora 44 hosts under systemd", because
systemd supplies service lifecycle, ordering, and boot activation for the quadlets with
no virtualization tier underneath. Each service deploys as an OCI container image
launched by a quadlet `.container` unit, with `.network` and `.volume` units alongside,
copied into `~/.config/containers/systemd` to match the quadlet deployment convention.
Deployment is OpenTofu in [infra](https://github.com/v-sekai-multiplayer-fabric/infra),
provisioning Fedora 44 hosts and delivering the quadlet units in place of baking and
booting qcow2 images on Harvester.

This supersedes [Self-host on Harvester HCI instead of
Fly.io](20260606-self-host-on-harvester-hci.md). Fly.io stays off the table from that
decision, and Harvester HCI joins it.

### Consequences

- Good: one fewer tier to build, ship, and operate — no hypervisor, no qcow2 pipeline,
  no VM lifecycle.
- Good: rootless podman under systemd is a well-documented path on Fedora, and the same
  OCI image runs in local dev, CI, and production.
- Good: a deploy rebuilds and pulls an OCI image rather than baking a VM image.
- Bad: services on one host share a kernel, so isolation between them is weaker than
  separate VMs give.
- Bad: host capacity planning and noisy-neighbor limits sit with the operator.
- Bad: the qcow2 `*-image` repos and any docs that target VMs need retiring or
  repointing at OCI images.

### Confirmation

The infra repo provisions Fedora 44 hosts via OpenTofu and brings each service up
through a podman quadlet unit under systemd, creating no Harvester HCI resources and no
qcow2 images. `systemctl --user status` reports the generated service units active, and
they survive a host reboot.

## More Information

Service images move from the qcow2 `*-image` VM repos to OCI container images; the
engine stays [pinned to a frozen Godot 4.7 commit](20260606-pin-engine-to-frozen-godot-4-7.md).
The verification smokes already run as a [systemd podman quadlet
queue](20260612-systemd-quadlet-verification-queue.md), so the runtime and its smokes
share one quadlet convention.
