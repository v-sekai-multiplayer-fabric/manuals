# V-Sekai Fire — Multiplayer Fabric

Documentation for the multiplayer fabric stack: a WebTransport-based game server platform built on Godot, Elixir, and CockroachDB, deployed on Fly.io.

- Source code: [V-Sekai-fire on GitHub](https://github.com/V-Sekai-fire)
- Issues and discussion: [multiplayer-fabric-taskweft](https://github.com/V-Sekai-fire/multiplayer-fabric-taskweft)

## Repositories

| Repo                                                                                                 | Purpose                                                 |
| ---------------------------------------------------------------------------------------------------- | ------------------------------------------------------- |
| [multiplayer-fabric-gateway](https://github.com/V-Sekai-fire/multiplayer-fabric-gateway)             | Elixir WebTransport gateway (WebRTC → Godot zone)       |
| [multiplayer-fabric-crdb](https://github.com/V-Sekai-fire/multiplayer-fabric-crdb)                   | CockroachDB with mTLS, role-separated access            |
| [multiplayer-fabric-uro](https://github.com/V-Sekai-fire/multiplayer-fabric-uro)                     | Phoenix zone backend (shard registry, asset API)        |
| [multiplayer-fabric-baker](https://github.com/V-Sekai-fire/multiplayer-fabric-baker)                 | Headless Godot asset validator and exporter             |
| [multiplayer-fabric-zone](https://github.com/V-Sekai-fire/multiplayer-fabric-zone)                   | Godot zone server (template_release, double precision)  |
| [multiplayer-fabric-observability](https://github.com/V-Sekai-fire/multiplayer-fabric-observability) | VictoriaMetrics + VictoriaLogs + Tempo + OTEL Collector |
| [multiplayer-fabric-infra](https://github.com/V-Sekai-fire/multiplayer-fabric-infra)                 | Terraform for Fly.io resources                          |
| [multiplayer-fabric-build](https://github.com/V-Sekai-fire/multiplayer-fabric-build)                 | V-Sekai fork of the Godot engine                        |
