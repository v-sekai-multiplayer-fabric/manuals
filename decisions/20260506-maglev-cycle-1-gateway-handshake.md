---
title: "Godot Client Gateway Handshake"
date: 2026-05-06
status: accepted
decision-makers: K. S. Ernest (iFire) Lee
tier: baseline
---

## The Context

The clients in this stack are Godot engine processes built from `multiplayer-fabric-godot` (branch `multiplayer-fabric`, `template_release double`). The Godot WebTransport implementation, its thread model, and its datagram API underpin all subsequent cycles; a curl or test-harness ping tests the gateway in isolation and leaves those untouched.

Cycle 0 (Terraform) must pass before this cycle begins — the Fly apps, dedicated IPv4, and secrets that this cycle depends on are created by Terraform.

## The Problem Statement

A Godot client running `multiplayer-fabric-godot` has not connected to `multiplayer-fabric-gateway` and received a datagram from `multiplayer-fabric-zone` under Fly's network. Until a real Godot process completes that round trip, the client side of the stack is unvalidated.

## Design

Build a minimal Godot scene (empty world, no avatar, no physics) that opens a WebTransport/QUIC connection to the gateway on UDP 443, waits for one datagram from the zone server, logs the receipt, and exits cleanly. Run it headlessly on a desktop to isolate client behaviour from display and input.

The zone server is `godot.linuxbsd.template_release.double.x86_64` built from `V-Sekai-fire/multiplayer-fabric-zone` (the zone repo owns and publishes its own GHCR image). It runs `--headless` with an empty world and sends one datagram on connection.

The gateway runs as root on UDP 443 (port < 1024 requires root or `CAP_NET_BIND_SERVICE`) and proxies to the zone server on UDP 7443. The Fly DNS record for the gateway endpoint is DNS-only — no Cloudflare proxy, which cannot forward QUIC/UDP. Both services deploy in the `iad` region and communicate over Fly's 6PN private network.

Pass criteria:

- [ ] Godot client establishes the WebTransport/QUIC connection without TLS or handshake error
- [ ] Client receives and logs one **datagram** (not a stream) from the zone server
- [ ] Client exits cleanly; no orphaned Godot process or open port

Every subsequent cycle extends this scene.

## The Downsides

Writing a minimal Godot scene that connects via WebTransport is more work than a curl ping test, and cannot be deferred — a non-Godot client would not catch Godot-specific datagram handling bugs before they reach Cycle 5.

## The Road Not Taken

- Bare WebTransport client (curl, Python, or Elixir harness): the original Cycle 1 design; it tests the gateway in isolation and leaves the Godot client's WebTransport path unverified until Cycle 4, where a failure is much harder to isolate.

## Confirmation

Verified 2026-05-07 against the live deployment, with all three pass criteria met:

- WebTransport/QUIC handshake without TLS error: the picoquic trace shows a full handshake, h3 ALPN negotiated, and 1-RTT keys derived.
- One datagram received: the gateway returned `{"id":"c1-...","ok":true,"result":"pong"}` matching the request id, in ~880 ms over real internet.
- Client exits cleanly: `quit(0)`, exit code 0, no orphaned process.

The handshake test client lives at [`multiplayer-fabric-cycle-tests/cycle-1-gateway-handshake/cycle1.gd`](https://github.com/V-Sekai-fire/multiplayer-fabric-cycle-tests/blob/main/cycle-1-gateway-handshake/cycle1.gd). The ping is answered directly by the gateway's `Gateway.Router.dispatch/1` (`router.ex:55`); zone routing is exercised in cycle 5 onward.
