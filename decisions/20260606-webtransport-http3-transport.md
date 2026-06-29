---
title: WebTransport over HTTP/3 transport
date: 2026-06-06
status: accepted
decision-makers: K. S. Ernest (iFire) Lee
tier: baseline
---

## Context and Problem Statement

The stack needs a client/server transport that carries reliable control messages
and high-rate unreliable state over one connection, on both native and web
clients. Which transport does the engine provide?

## Decision Drivers

- Unreliable datagrams for high-rate state, plus reliable streams for control.
- One connection for both, with native and browser support.

## Considered Options

- Standard `MultiplayerPeer` transports (ENet, WebSocket, WebRTC).
- WebTransport over HTTP/3 / QUIC.

## Decision Outcome

Chosen option: "WebTransport over HTTP/3", provided by the engine's `modules/http3`
(on `feat/module-http3`):

- `quic_picoquic_backend.{cpp,h}` — native QUIC via picoquic.
- `quic_web_backend.cpp` + `quic_web_glue.js` — the web/wasm backend.
- `http3_client.{cpp,h}`, `quic_client.{cpp,h}`, `quic_server.h`.
- Classes `HTTP3Client`, `QUICClient`, `QUICServer`, `WebTransportPeer`.
- Demos: `modules/http3/demo/wt_client_test.gd`, `wt_server_demo.gd`,
  `wt_browser_test.html`.
- `lean/http3/PollingTermination.lean` proves the poll loop terminates.

One QUIC connection carries reliable streams and unreliable datagrams, so control
messages and high-rate state share a connection.

### Consequences

- Good: datagrams suit high-rate state; one connection serves native and browser.
- Bad: the fork carries a picoquic backend and a QUIC stack to maintain.

### Confirmation

The `modules/http3` demos open a WebTransport client and server over QUIC.

## More Information

Pose streaming for the presence demo rides this transport; see
presence demo pose networking.
The engine is [pinned to a frozen Godot 4.7 commit](20260606-pin-engine-to-frozen-godot-4-7.md).
