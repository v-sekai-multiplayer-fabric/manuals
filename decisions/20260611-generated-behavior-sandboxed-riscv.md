---
title: Generated behavior runs as sandboxed RISC-V
date: 2026-06-11
status: accepted
decision-makers: K. S. Ernest (iFire) Lee
---

## Context and Problem Statement

Enemy and ability behavior may be generated, and running generated logic in-process risks the whole instance. The combat hexagon's `behavior_source` port needs a safe implementation.

## Decision Outcome

Chosen option: run generated enemy and art behavior as sandboxed RISC-V programs through `feat/sandbox`, implementing the combat `behavior_source` port, because the sandbox contains a misbehaving program rather than letting it take down the instance. This is the runtime guarantee under the bounded, declarative vocabulary the AI emits.

## Consequences

- Generated logic is isolated, so a bad program degrades one entity rather than the instance.
- Behavior is an adapter behind a port, so a fixture adapter replays scripted intents for CI.
- The same port accepts hand-written and generated behavior.

## Confirmation

A misbehaving generated program is contained without taking down the instance, and the fixture adapter reproduces scripted intents with no sandbox.
