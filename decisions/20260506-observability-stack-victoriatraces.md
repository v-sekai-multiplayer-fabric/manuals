---
title: Replace Jaeger with VictoriaTraces for trace storage
date: 2026-05-06
status: accepted
supersedes: 20260506-observability-stack-victoriametrics-jaeger.md
---

## Context

Jaeger all-in-one with Badger storage was chosen as the Apache 2.0 replacement for Tempo. However, VictoriaMetrics (the same vendor as VictoriaMetrics and VictoriaLogs already in the stack) ships VictoriaTraces — an Apache 2.0 trace backend that accepts OTLP directly and claims 3.7× less RAM and 2.6× less CPU than Tempo.

Using VictoriaTraces gives us a unified vendor stack (VictoriaMetrics / VictoriaLogs / VictoriaTraces), eliminates Badger's single-node limitation, and follows the same port and CLI-flag conventions as the other Victoria services.

## Decision

Replace Jaeger all-in-one with VictoriaTraces in the single-machine observability stack.

- VictoriaTraces listens on 10428 (HTTP, UI + query + OTLP HTTP ingest).
- OTEL Collector exports traces via `otlphttp/traces` to `http://localhost:10428/insert/opentelemetry`.
- Data persists at `/var/lib/victoriatraces` on the shared Fly volume.
- Jaeger is removed entirely; no separate query UI process is needed.

Port map after this change:

| Service | Port | Purpose |
|---------|------|---------|
| VictoriaMetrics | 8428 | Metrics storage and PromQL |
| VictoriaLogs | 9428 | Log storage and query |
| VictoriaTraces | 10428 | Trace storage and query |
| OTEL Collector | 4317 (gRPC), 4318 (HTTP) | OTLP ingest, routes to the above |

## Consequences

- All four services are now Apache 2.0 and from the VictoriaMetrics ecosystem.
- VictoriaTraces query UI is at `http://...:10428/select/vmui`.
- `fly proxy 10428:10428` replaces the former `fly proxy 16686:16686` for trace inspection.
- No explicit trace TTL is configured; add `-retentionPeriod` if disk pressure becomes a concern.
