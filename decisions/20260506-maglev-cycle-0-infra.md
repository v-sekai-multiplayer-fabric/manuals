# Maglev Cycle 0: Terraform Fly.io Infrastructure

## The Context

All Fly services — gateway, zone, uro, CockroachDB, observability stack — depend on Terraform having created their Fly apps, dedicated IPs, volumes, and secrets. Without applied Terraform state, no Fly app exists to deploy to and no subsequent cycle can run.

## The Problem Statement

Terraform has not been applied and verified under the current infra config in `multiplayer-fabric-infra`. Until the Fly provider confirms that all resources exist and match the declared state, the deployment is unverifiable.

## Design

Run `terraform apply` in `multiplayer-fabric-infra`. Verify via Fly CLI:

- `fly status --app multiplayer-fabric-gateway` exits 0
- CockroachDB volume exists and is attached to the uro app
- uro app exists and is reachable on the 6PN private network
- Observability app exists with persistent volume

Pass criteria:
- [ ] `fly status --app multiplayer-fabric-gateway` shows running; dedicated IPv4 assigned
- [ ] CockroachDB volume attached; `fly volumes list` confirms the volume is in the correct region
- [ ] uro app reachable on Fly's 6PN private network
- [ ] Secrets for mTLS certs present (`fly secrets list` shows expected keys for gateway and uro)

## CRIS Score

| Factor          | Score | Evidence |
| --------------- | ----- | -------- |
| **C**omplexity  | 8     | Terraform is well-understood; the only unknowns are Fly provider version quirks against the current config. |
| **R**each       | 10    | Every subsequent cycle runs on infrastructure created here. |
| **I**mpediment  | 10    | No Fly app can be deployed until Terraform apply succeeds. |
| **S**takeholder | 10    | Gate for all Maglev cycles. |
| **Total**       | 9.5   | Build before all other cycles. |

## The Downsides

Terraform state must be kept in sync with any manual Fly CLI changes. A drift between Terraform state and actual Fly resources will cause `terraform apply` to fail or, worse, silently produce the wrong configuration.

## The Road Not Taken

Running `flyctl deploy` manually without Terraform was rejected — untracked infrastructure state makes the deployment unreproducible and leaves secrets and volumes outside version control.

## Status

Status: Draft

## Decision Makers

- Lead Architect / Fabric Maintainer

## Tags

- maglev-cycle-0, infra, terraform, fly-io, galls-law, 20260506-maglev-cycle-0-infra, present-proposal-template

## Further Reading

```
@techreport{20260501_fly,
  title       = {Fly.io for deployment},
  institution = {V-Sekai Fire},
  year        = {2026},
  type        = {Architecture Decision Record},
  note        = {decisions/20260501-fly-io-for-deployment.md}
}

@techreport{20260501_crdb,
  title       = {CockroachDB with mTLS and role-separated access},
  institution = {V-Sekai Fire},
  year        = {2026},
  type        = {Architecture Decision Record},
  note        = {decisions/20260501-cockroachdb-with-mtls-role-separation.md}
}

@misc{v_sekai_2026,
  title = {V-Sekai},
  year  = {2026},
  url   = {https://v-sekai.org/}
}
```
