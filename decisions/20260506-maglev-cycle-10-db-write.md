# Maglev Cycle 10: CockroachDB Score Write

## The Context

With causal ordering confirmed in Cycle 8 and the DB connection verified in Cycle 9, Cycle 10 activates persistence: the persona zone commits the score and `multiplayer-fabric-uro` writes it to CockroachDB.

## The Problem Statement

The cross-zone write path — persona zone commits, uro writes via Ecto over Fly's 6PN using the `gateway_writer` role — requires end-to-end validation. With causal ordering confirmed in Cycle 8, the only remaining unknown is whether the database write path performs correctly under mission load.

## Design

On each core-slot event the persona zone commits the score update after the `VClock.le` check passes. On mission end `multiplayer-fabric-uro` writes the committed score to CockroachDB via Ecto over Fly's 6PN using the `gateway_writer` role. `RelReplica` entries stamped with `sentAt` are broadcast to the interest band.

Write path:

```
spatial zone  →  QueueOp(VClock)  →  persona zone commits
              →  uro → CockroachDB (gateway_writer, Fly 6PN)
              →  RelReplica(sentAt) broadcast to interest band
```

Pass criteria:
- [ ] Committed score appears in CockroachDB within one tick of mission end
- [ ] `RelReplica.stale` correctly reflects the write on all nodes in the interest band
- [ ] No write occurs from any zone other than the persona authority

## CRIS Score

| Factor          | Score | Evidence |
| --------------- | ----- | -------- |
| **C**omplexity  | 6     | The Ecto write path to CockroachDB over Fly's 6PN under concurrent mission load is untested in this codebase. |
| **R**each       | 10    | Persistent player progression requires this path. |
| **I**mpediment  | 8     | A broken score write does not block Cycle 8 gameplay but blocks any feature that depends on persistent state. |
| **S**takeholder | 10    | Required for the full Maglev Intercept scenario. |
| **Total**       | 8.0   | Build after Cycles 8 and 9 pass. |

## The Downsides

If the persona zone goes down, that player's attributes are offline until it recovers. Replication factor ≥ 2 on the persona partition is the mitigation, deferred to a later cycle.

## The Road Not Taken

Writing scores directly from the spatial zone to CockroachDB was considered. Rejected — it violates `DisjointRanges` and allows concurrent writes to the same player record.

## Status

Status: Draft

## Decision Makers

- Lead Architect / Fabric Maintainer

## Tags

- maglev-cycle-10, db-write, persona-zone, cockroachdb, galls-law, 20260506-maglev-cycle-10-db-write, present-proposal-template

## Further Reading

```
@misc{v_sekai_2026,
  title = {V-Sekai},
  year  = {2026},
  url   = {https://v-sekai.org/}
}
```
