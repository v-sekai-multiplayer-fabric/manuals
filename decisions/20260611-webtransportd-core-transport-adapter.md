---
title: webtransportd as the out-of-process core transport adapter
date: 2026-06-11
status: accepted
decision-makers: K. S. Ernest (iFire) Lee
---

## Context and Problem Statement

The cores expose a flat C ABI and need a transport adapter to carry their port traffic to clients. The fabric already runs WebTransport over QUIC for game traffic ([the transport decision](20260501-webtransport-over-quic-for-game-traffic.md)) and ships an in-engine implementation. A standalone bridge is also available: `webtransportd` pipes a connection's bytes to a child program over stdin and stdout.

## Decision Outcome

Chosen option: use `webtransportd` as the out-of-process transport adapter for the event-driven cores, and keep the in-engine `feat/module-http3` for the in-process authoritative tick core, because the tick core needs shared state and low latency in the `zone-server`, while the event-driven cores fit a piped child cleanly.

A driving port reads frames from stdin and a driven port writes frames to stdout, framed as `[flag | varint len | payload]`, where the flag bit selects a reliable stream or an unreliable datagram and maps to the port's reliability. One authoritative core per instance funnels the four connections, so a per-connection child relays to that single core rather than holding state itself.

## Consequences

- The cores stay transport-agnostic behind their ports, so a fixture adapter replays frames for CI with no daemon and no network.
- The reliable and datagram flag bit maps onto port reliability, so combat input stays reliable and pose updates stay lossy.
- The per-connection process model needs the funnel relay, so a single core owns the authoritative instance state.

## Confirmation

A core round-trips frames through `webtransportd` in a CLI smoke test, and the fixture adapter reproduces the same exchange with no network.
