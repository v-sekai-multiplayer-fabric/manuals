# Maglev Cycle 1: Godot Client Gateway Handshake

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

## Estimate

**2 days** (2026-05-07 → 2026-05-08). The gateway was built from scratch in one day (25+ commits on 2026-05-05); the zone server initial deploy took two days (2026-05-05–06). The remaining work is a minimal headless Godot scene that connects and logs one datagram.

## CRIS Score

| Factor          | Score | Evidence                                                                                                                                                                                                                                                                                                        |
| --------------- | ----- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **C**omplexity  | 6     | Godot's WebTransport datagram API is documented but untested in this build config; the Fly UDP routing adds one unknown. The wtransport Rust library (v0.7.1) carries an upstream disclaimer that it is not yet considered production-ready; the WebTransport protocol itself is standardized (RFC 9220, 2023). |
| **R**each       | 10    | Every subsequent cycle runs inside this Godot client.                                                                                                                                                                                                                                                           |
| **I**mpediment  | 10    | Nothing else can be tested until a real Godot process receives a datagram end-to-end.                                                                                                                                                                                                                           |
| **S**takeholder | 10    | Gate for all Maglev cycles.                                                                                                                                                                                                                                                                                     |
| **Total**       | 9.0   | Build first.                                                                                                                                                                                                                                                                                                    |

## The Downsides

Writing a minimal Godot scene that connects via WebTransport is more work than a curl ping test, and cannot be deferred — a non-Godot client would not catch Godot-specific datagram handling bugs before they reach Cycle 5.

## The Road Not Taken

A bare WebTransport client (curl, Python, or Elixir test harness) was the original Cycle 1 design but was rejected because it only tests the gateway in isolation, leaving the Godot client's WebTransport implementation unverified until Cycle 4, where any failure would be much harder to isolate.

## Status

Status: Draft

## Decision Makers

- Lead Architect / Fabric Maintainer

## Tags

- maglev-cycle-1, godot-client, gateway-handshake, webtransport, smoke-test, galls-law, 20260506-maglev-cycle-1-gateway-handshake, present-proposal-template

## Further Reading

```
@techreport{20260501_webtransport,
  title       = {Use WebTransport over QUIC for game traffic},
  institution = {V-Sekai Fire},
  year        = {2026},
  type        = {Architecture Decision Record},
  note        = {decisions/20260501-webtransport-over-quic-for-game-traffic.md}
}

@techreport{20260501_godot_precision,
  title       = {Godot double precision template\_release for zone servers},
  institution = {V-Sekai Fire},
  year        = {2026},
  type        = {Architecture Decision Record},
  note        = {decisions/20260501-godot-double-precision-template-release-for-zone.md}
}

@techreport{20260501_fly,
  title       = {Fly.io for deployment},
  institution = {V-Sekai Fire},
  year        = {2026},
  type        = {Architecture Decision Record},
  note        = {decisions/20260501-fly-io-for-deployment.md}
}

@techreport{20260506_ghcr,
  title       = {GHCR packages must be built by the repo that consumes them},
  institution = {V-Sekai Fire},
  year        = {2026},
  type        = {Architecture Decision Record},
  note        = {decisions/20260506-ghcr-package-ownership-same-repo.md}
}

@misc{v_sekai_2026,
  title = {V-Sekai},
  year  = {2026},
  url   = {https://v-sekai.org/}
}
```
