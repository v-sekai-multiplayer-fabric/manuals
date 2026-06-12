---
title: Lean 4 build-time kernel cores with flat-C host adapters
date: 2026-06-11
status: accepted
decision-makers: K. S. Ernest (iFire) Lee
---

## Context and Problem Statement

The hexagonal cores ([the hexagonal decision](20260610-hexagonal-core-ports-adapters.md)) hold dependency-free domain logic that Godot, the Elixir backend, and a CLI all bind. The team wants strong spec and proof guarantees on that logic without linking a heavy language runtime into every host. The `idtx-flow` repository already explores this shape in its `LEAN_KERNELS_HOST_ADAPTERS` investigation.

## Considered Options

- Link the Lean runtime into each host and call exported Lean functions over a C ABI.
- Hand-write the cores in flat C with no Lean involvement.
- Use Lean 4 at build time for the spec and code generation, and ship a flat-C runtime core.

## Decision Outcome

Chosen option: use Lean 4 at build time as the kernel, the spec, and the code generator, and ship each runtime core as a flat C ABI behind the port ring with no Lean runtime linked into any host, because this keeps the proof leverage while the hosts bind only a flat C surface. The first option links a heavy runtime and marshals Lean objects across every boundary; the second option loses the spec and proof leverage.

Each core models a pure reducer over byte-serialized state, so it is bytes to bytes. The compute kernels are authored in Lean and lowered to Slang through [lean-slang](https://github.com/V-Sekai-fire/lean-slang), then `slangc -target spirv` lowers the Slang to SPIR-V, and the runtime core dispatches the `.spv` compute kernel behind the flat C ABI, byte-pinned beside the core ([the codegen decision](20260611-core-codegen-lean-slang.md)). The spec suite drives the C ABI through Python ctypes, the property tests run on Plausible, and a handful of theorems pin the invariants that never break. This mirrors `idtx-flow`, where `flow/core` compiles to a flat-C library, `flow/ports` is the flat C ABI, and `flow/core/spec` drives that ABI through ctypes with no engine and no hardware.

## Consequences

- A host binds only the flat C ABI and never sees core internals or a Lean runtime.
- CI runs the cores headless on the workstation, with no engine and no device.
- Lean stays a build-time tool, so the runtime carries no Lean dependency.

## Confirmation

Each core passes its ctypes fixture suite and its Plausible properties in CI, and no host binary links a Lean runtime.
