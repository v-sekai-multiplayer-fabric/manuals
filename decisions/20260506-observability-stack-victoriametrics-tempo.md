---
title: Observability stack with VictoriaMetrics, VictoriaLogs, and Tempo
date: 2026-05-06
status: accepted
---

## Context

The stack needs metrics, logs, and traces. Options considered: Grafana Cloud (cost), self-hosted Prometheus+Loki+Tempo (three separate apps), or a compact single-machine stack.

## Decision

Run VictoriaMetrics (metrics), VictoriaLogs (logs), and Grafana Tempo (traces) under supervisord in a single Fly Machine, with an OpenTelemetry Collector as the ingest router.

- OTEL Collector listens on 4317 (gRPC) and 4318 (HTTP) on the private network.
- Collector routes: metrics → VictoriaMetrics (8428 via Prometheus remote write), logs → VictoriaLogs (9428 OTLP), traces → Tempo (5317 OTLP internal).
- Data persists on a 10 GB Fly volume.

## Consequences

- OTLP ports must not be exposed publicly — they accept unauthenticated writes.
- Other Fly apps send telemetry to `multiplayer-fabric-observability.internal:4317` or `:4318`.
- Grafana Tempo v3 config changed significantly from v2: `ingester` and `compactor` top-level keys were removed; `-target=all` flag is required to run all components.
- The GHCR image `godot-zone-double` was originally owned by `multiplayer-fabric-baker`. Package ownership is tied to the creating repository's token, so the zone binary build was moved to `multiplayer-fabric-zone` and renamed to `multiplayer-fabric-zone-godot`.
