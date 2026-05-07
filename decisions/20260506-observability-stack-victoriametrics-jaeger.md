---
title: Observability stack with VictoriaMetrics, VictoriaLogs, and Jaeger
date: 2026-05-06
status: superseded by [20260506-observability-stack-victoriatraces.md](20260506-observability-stack-victoriatraces.md)
supersedes: 20260506-observability-stack-victoriametrics-tempo.md
---

## Context

Grafana Tempo was chosen for trace storage in the initial stack but is licensed under AGPL-3.0, which requires any service modifications to be open-sourced. Jaeger (Apache 2.0, CNCF graduated) fits the permissive-license constraint: it is OTLP-native since v1.35 and commonly deployed alongside VictoriaMetrics.

## Decision

Replace Grafana Tempo with Jaeger all-in-one in the single-machine observability stack.

- Jaeger listens on 14317 (OTLP gRPC, internal) and exposes its UI on 16686.
- OTEL Collector routes traces to `localhost:14317` instead of the former Tempo port (5317).
- Jaeger uses Badger embedded storage (`/var/lib/jaeger/data` and `/var/lib/jaeger/keys`) persisted on the same 10 GB Fly volume.
- `tempo-config.yaml` is deleted; Jaeger is configured entirely via CLI flags in `supervisord.conf`.

Port map after this change:

| Service         | Port                     | Purpose                          |
| --------------- | ------------------------ | -------------------------------- |
| VictoriaMetrics | 8428                     | Metrics storage and PromQL       |
| VictoriaLogs    | 9428                     | Log storage and query            |
| Jaeger UI       | 16686                    | Trace storage and query          |
| OTEL Collector  | 4317 (gRPC), 4318 (HTTP) | OTLP ingest, routes to the above |

## Consequences

- Jaeger UI replaces the Tempo query endpoint: `fly proxy 16686:16686` instead of `fly proxy 3200:3200`.
- Badger is ephemeral-safe only with `--badger.ephemeral=false`; this flag must be set or traces are lost on restart.
- No explicit trace TTL is configured; traces accumulate until disk pressure. Add `--badger.span-store-ttl` if retention limits are needed.
- Jaeger's Badger backend does not support distributed mode; acceptable for a single-machine stack.
