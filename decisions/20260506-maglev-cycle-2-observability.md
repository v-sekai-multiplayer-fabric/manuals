# Maglev Cycle 2: Observability Stack

## The Context

The observability stack — OTEL Collector (4317/4318), VictoriaMetrics (8428), VictoriaLogs (9428), VictoriaTraces (10428) — is infrastructure-level and depends only on the Fly deployment being live after Cycle 1. It can run in parallel with the game-logic track (Cycles 3–10) and the DB connection (Cycle 9).

## The Problem Statement

No cycle verifies that traces from `multiplayer-fabric-gateway`, `multiplayer-fabric-zone`, and `multiplayer-fabric-uro` reach VictoriaTraces, or that metrics reach VictoriaMetrics. Without this, any failure in Cycles 3–10 has no trace evidence to debug against.

## Design

Start the observability stack on the Fly deployment:

- VictoriaMetrics on port 8428
- VictoriaLogs on port 9428
- VictoriaTraces on port 10428 (replaces Jaeger; `fly proxy 10428:10428` for local inspection)
- OTEL Collector on 4317 (gRPC) and 4318 (HTTP), routing to all three backends

Trigger a single gateway request and a single zone tick. The zone server binary includes the `opentelemetry-godot` module compiled into the engine (verify with `--test --test-case="*OTel*"` before the run). Verify each service emits OTLP spans to the Collector.

Pass criteria:

- [ ] VictoriaTraces UI at `http://localhost:10428/select/vmui` shows spans from at least one gateway request
- [ ] VictoriaMetrics at port 8428 returns a non-empty result for a zone-server metric query
- [ ] VictoriaLogs at port 9428 shows at least one log line from uro
- [ ] All four services are Apache 2.0 (no Tempo, no Jaeger)

## Estimate

**3 days** (2026-05-09 → 2026-05-13, parallel). VictoriaMetrics/Logs/Traces share a config pattern; the only unknown is Fly volume persistence. Comparable to the zone-console Fly deploy (2 days of config commits on 2026-04-24–25).

## CRIS Score

| Factor          | Score | Evidence                                                                                                                                                                            |
| --------------- | ----- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **C**omplexity  | 7     | All four Victoria backends share port conventions and the OTEL Collector config is well-documented; the only unknown is Fly volume persistence under the single-machine deployment. |
| **R**each       | 10    | Every failure in Cycles 3–10 requires trace evidence to diagnose; without this cycle no networking or physics failure is attributable.                                              |
| **I**mpediment  | 7     | A missing observability stack does not block Cycles 3–10 but leaves failures in Cycles 3–10 impossible to root-cause.                                                               |
| **S**takeholder | 10    | Required for any post-mission debugging of physics desync or score write failures.                                                                                                  |
| **Total**       | 8.5   | Build after Cycle 1 passes, in parallel with Cycles 9 and 6–11. Must complete before Cycle 3 begins.                                                                                |

## The Downsides

A passing Cycle 2 does not validate trace volume or retention under mission load; that stress only appears during Cycles 9–2.

## The Road Not Taken

Deferring observability to after Cycle 11 was rejected — a failure in Cycle 8 (dynamic physics) or Cycle 10 (score write) with no trace evidence requires rerunning the entire cycle with instrumentation added, doubling the debugging time.

## Status

Status: In Progress (producer side complete 2026-05-07; verification pending)

The observability stack itself is deployed and running on Fly (machine
`781ed59b437968` started, volume `observability_data` 10GB iad attached) per
`verify_fly_state` workflow output. The producer side has now been wired in
all three apps:

- ✅ [gateway PR #8](https://github.com/V-Sekai-fire/multiplayer-fabric-gateway/pull/8) — `:opentelemetry` deps + `gateway.dispatch` span around `Gateway.Router.handle/1`
- ✅ [uro PR #13](https://github.com/V-Sekai-fire/multiplayer-fabric-zone-backend/pull/13) — `:opentelemetry_phoenix` + `:opentelemetry_ecto` automatic instrumentation
- ✅ [zone PR #3](https://github.com/V-Sekai-fire/multiplayer-fabric-zone/pull/3) — bootstrapped `project/main.gd` initializing the engine's `module_open_telemetry`, emits `zone.boot` span

All ship to `multiplayer-fabric-observability.internal:4318` (OTLP/HTTP over
Fly's 6PN). End-to-end verification runs via
[`.github/workflows/verify_observability.yml`](https://github.com/V-Sekai-fire/multiplayer-fabric-infra/blob/main/.github/workflows/verify_observability.yml)
on `multiplayer-fabric-infra` — uses `flyctl ssh console -C` to query the
Victoria\* APIs from inside the observability machine (the OTLP ports are
intentionally private). Pending: trigger the verify workflow after redeploys
land and confirm the cycle 1 ping span is visible in VictoriaTraces.

## Decision Makers

- Lead Architect / Fabric Maintainer

## Tags

- maglev-cycle-2, observability, victoriatraces, victoriametrics, otel, galls-law, 20260506-maglev-cycle-2-observability, present-proposal-template

## Further Reading

```
@techreport{20260506_observability_victoriatraces,
  title       = {Replace Jaeger with VictoriaTraces for trace storage},
  institution = {V-Sekai Fire},
  year        = {2026},
  type        = {Architecture Decision Record},
  note        = {decisions/20260506-observability-stack-victoriatraces.md}
}

@misc{v_sekai_2026,
  title = {V-Sekai},
  year  = {2026},
  url   = {https://v-sekai.org/}
}
```
