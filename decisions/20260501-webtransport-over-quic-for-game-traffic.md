---
title: Use WebTransport over QUIC for game traffic
date: 2026-05-01
status: accepted
decision-makers: K. S. Ernest (iFire) Lee
tier: baseline
---

## Context

The zone server needs low-latency bidirectional communication between clients and the Godot game server. HTTP/1.1 and WebSocket both run over TCP, which head-of-line blocks on packet loss and degrades real-time game state.

## Decision

Use WebTransport (HTTP/3 over QUIC) for all game traffic. Clients connect to the Elixir gateway on UDP port 443, which proxies into the Godot zone server on UDP port 7443.

## Consequences

- UDP eliminates TCP head-of-line blocking.
- Fly.io passes UDP without DNAT, so the app must bind to the same port clients connect to.
- Port 443 requires running as root (or CAP_NET_BIND_SERVICE). The gateway container runs as root.
- Datagrams are used for game state messages. Streams are avoided for ping/pong to sidestep stream half-close deadlock (client must close write side before server response fires).
- Cloudflare's proxy cannot forward QUIC/UDP. All game-traffic DNS records must be DNS-only (no proxy).
