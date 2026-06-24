---
title: Hexagonal core/ports/adapters as the component convention
date: 2026-06-10
status: accepted
decision-makers: K. S. Ernest (iFire) Lee
---

## Context and Problem Statement

Components in the stack span several languages (C, C++, Python, Elixir, GDScript), run as
separate processes, and each binds to hardware, a GPU, the network, or an engine runtime. A
component has to stay testable without its device, replaceable without a rewrite of its callers,
and composable with components written in another language. A shared monolith or a single
in-memory object model does not hold across those boundaries.

## Decision Drivers

- Real-time and pipeline paths cross process and language boundaries with no shared object model.
- Hardware, OS, GPU, network, and engine concerns have to stay out of the domain logic, or that
  logic becomes untestable away from the live system.
- CI runs the domain logic against recorded fixtures, without the device or the runtime.
- One computed result often feeds several outputs from a single pass.

## Decision Outcome

Each component is a hexagon with a uniform `core/` + `ports/` + `adapters/` layout, and components
compose into a cluster by wiring ports across the boundary.

### core/ — dependency-free domain logic

`core/` holds the component's domain logic and nothing else: it opens no socket, reads no device,
and links no framework. It carries its own `core/spec/` of tests that run in isolation against
fixtures. A transport never reaches into the core.

### ports/ — interface contracts, labelled by direction

A port is a narrow interface the core defines and an adapter implements. Each port is labelled by
its side of the hexagon and by its data direction:

- driving (primary) ports carry input the outside world pushes into the core;
- driven (secondary) ports carry the core's output back out to the outside world;
- by data flow, a `*_source` port reads data in and a `*_sink` port writes data out.

A port stays at the lowest common denominator every binding language can implement: a C-ABI struct
of function pointers where the cluster crosses languages, a language-native interface where it does
not. One header then binds C, C++, and Python adapters alike.

### adapters/ — concrete I/O at the edges

Adapters implement the ports against the real world: a serial device, a UDP socket, a recorded
fixture for CI, a GPU compute host, a renderer, an engine runtime. One port admits many adapters,
so a single core output fans out to several destinations from one pass, and a recorded-fixture
adapter stands in for live hardware under CI.

### Cluster composition — wiring ports across the seam

Components compose by connecting one component's sink to another's source. An in-process dependency
links the sibling directly; a cross-process dependency meets on a wire, a network protocol the two
ends share. The wire is the integration contract, so a producer in one language and a consumer in
another share no code, only the message format. Each component declares its sibling wiring alongside
its ports.

## Consequences

- A dependency-free core lets CI replay recorded fixtures through the domain logic with no device
  and no runtime.
- The wire seam decouples languages and processes, so any component is rewritable or replaceable as
  long as it keeps the message contract.
- A new output is a new sink adapter, with no change to the core that produced the data.
- The driving and driven labels keep the dependency direction explicit: adapters depend on the core
  through ports, and the core depends on nothing.
- The convention costs interface boilerplate, and across a process boundary it adds a serialize and
  parse step the in-process link avoids. That cost buys cross-language, cross-process composition.

## More Information

The `sinew-mocap` cluster applies the pattern end to end. Each repository (`driver`, `mount_drift`,
`solve`, `viewer`, `vr_bridge`) carries the `core/` + `ports/` + `adapters/` triad; ports are
header-only C struct vtables labelled driving or driven and named `*_source.h` / `*_sink.h`
(FrameSource, TrackerSink, PoseSink, HmdSource); adapters bind the serial dongle, a recorded
`.rawlog`, UDP, polyscope, SteamVR, OpenVR, and Vulkan; and the repositories compose over the
`/sinew` OSC wire (UDP 39539), with each `ports/sibling-repos.txt` declaring the wiring. The
synthetic-data branch in `sinew-vrdance/pose_distill` applies the same triad in Python: core
geometry and label cleaning, ports for the teacher pose model, renderer, and dataset sink, and
adapters for the model, the Godot renderer, and the COCO sink.
