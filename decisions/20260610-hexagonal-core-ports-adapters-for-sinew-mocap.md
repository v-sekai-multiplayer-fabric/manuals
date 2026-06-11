---
title: Hexagonal core/ports/adapters for the Sinew mocap cluster
date: 2026-06-10
status: accepted
---

## Context and Problem Statement

The Sinew mocap stack is a real-time pipeline — IMU dongle → calibration → body
solve → render / VR runtime — spread across the seven `sinew-mocap`
repositories in three implementation languages:

| repo | language | role |
| --- | --- | --- |
| `driver` | C | reads the rebocap dongle (36-byte serial frames), emits `/sinew` OSC |
| `mount_drift` | Python | TIC calibrator (mount/drift) + the `vkc` Vulkan-compute host |
| `solve` | C | FK + LBS skinning of the ANNY body |
| `viewer` | C++ | polyscope PoseSink — `/sinew` OSC in, body solve, ANNY render |
| `vr_bridge` | C++ | VR PoseSink — presents trackers to a VR runtime, reads HMD poses |
| `homebrew-sinew` | Ruby | Homebrew tap (packaging) |
| `scoop-bucket` | — | Scoop bucket (Windows packaging) |

Every stage touches hardware, the network, or a GPU (serial dongle, UDP, OpenVR,
Vulkan, polyscope), and the path crosses both process and language boundaries.
The stack needs each stage to stay independently testable and swappable without a
shared monolith, a single language runtime, or a common object model.

## Decision Drivers

- The real-time path spans a C producer, a Python calibrator, and C++ consumers —
  no shared in-memory type system links them.
- Hardware / OS / GPU / network concerns must not leak into the pose math, or the
  codec and solve become untestable off the physical rig.
- CI runs the codec, solve, and calibration without the dongle or a headset.
- A single solved pose feeds several outputs (polyscope viewer, SteamVR, VMC)
  from one solve pass.

## Decision Outcome

Each repository is an independent **hexagon** with a uniform
`core/` + `ports/` + `adapters/` layout, and the hexagons compose into a
**cluster** by wiring ports across repos. Each repo's `README.md` states the same
contract: *"A hexagon cluster (`core/` + `ports/` + `adapters/`) of the Sinew
mocap stack."*

### `core/` — transport-free domain logic

The codec (`sinew_protocol.c`, `sinew_osc.c`), hardware-id and channel maps, FK +
LBS skinning (`vk_lbs_host.cpp`, `soma_rig.h`), the TIC calibrator
(`tic_calib.c`), and the VR tracker math (`vr_trackers.c`) live in `core/`. Core
reads no socket, opens no device, and carries a `core/spec/` of tests it runs in
isolation. A port comment states the rule directly: *"keeps the core codec out of
any transport."*

### `ports/` — header-only source/sink contracts

Ports are C struct vtables (`void *ctx` + function pointers), header-only, each
labelled **driving (primary)** or **driven (secondary)** in its header, and named
by direction:

- `*_source.h` — inbound: `FrameSource` (raw 36-byte frames), `TrackerSource`
  (`/sinew` OSC), `HmdSource`, `VrSource`, `PoseSource`.
- `*_sink.h` — outbound: `TrackerSink` (`/sinew` OSC), `PoseSink` (solved
  joints), `TrackedDeviceSink`, `VrOscSink`, `CommandSink`.

A port is the lowest-common-denominator C ABI on purpose — a `FrameSource` is a
`next(ctx, frame36) -> int` / `close(ctx)` pair; a `PoseSink` emits a
`SinewJointPose[]` (quaternion + position per joint) plus a timestamp. Nothing
richer, so C, C++, and Python adapters all bind the same header.

### `adapters/` — concrete I/O at the edges

Adapters bind ports to the real world: the serial host and a recorded `.rawlog`
source (`driver`), the UDP socket, the polyscope viewer and `anny_demo`
(`viewer`), the SteamVR `driver_sinew` and OpenVR `hmd_reader` (`vr_bridge`), the
Vulkan `vkc` host and training scripts (`mount_drift`). One port admits many
adapters: `PoseSink` fans a single solve out to polyscope + SteamVR + VMC —
*"fanning the solve out through one port is what lets the server drive all three
from a single solve pass."*

### Cluster wiring — the `/sinew` OSC seam

Each `ports/sibling-repos.txt` declares how its hexagon connects to siblings, in
two kinds: *"in-process deps link `../<repo>`; network deps use OSC."* The
cross-process seam is the `/sinew` OSC wire over UDP — the same `/sinew/tracker` +
`/sinew/accel` bytes a `driver` `TrackerSink` emits on UDP 39539 are what a
`viewer`/`vr_bridge` `TrackerSource` consumes. The wire is the integration
contract, so a C producer and a C++/Python consumer share no code:

```
driver ──/sinew OSC (UDP 39539)──▶ viewer      (TrackerSource → core solve → PoseSink → polyscope)
       └─────────────────────────▶ vr_bridge   (TrackerSource → core → TrackedDeviceSink → SteamVR)
mount_drift  (TIC calibration: mount/drift)        vr_bridge HmdSource ◀── OpenVR HMD
solve        (FK + LBS skinning of ANNY, vkc)
```

## Consequences

- **Testable without the rig.** A pure `core/` lets CI replay a recorded
  `.rawlog` through the codec and solve with no dongle and no headset; the
  `core/spec/` tests run standalone.
- **Language-decoupled.** The `/sinew` OSC seam isolates languages — any hexagon
  is rewritable or replaceable as long as it speaks `/sinew`; the C driver, Python
  calibrator, and C++ viewer never link each other.
- **New output = a new adapter.** Adding VMC-out or a second renderer is a new
  `PoseSink` adapter, with no change to `core/` solve.
- **Explicit dependency direction.** The driving/driven labels make the rule
  visible: adapters depend on `core` through `ports`; `core` depends on nothing.
- **Cost — boilerplate and a serialization seam.** Each port vtable and
  `sibling-repos.txt` is hand-kept wiring to keep in sync, and the OSC wire adds a
  serialize/parse step the in-process link path avoids; the source/sink split is
  accepted as the price of cross-language, cross-process composition.

## More Information

- Repos: `sinew-mocap/{driver, mount_drift, solve, viewer, vr_bridge}` (hexagon
  clusters); `homebrew-sinew`, `scoop-bucket` (packaging).
- Each repo's `README.md` and `ports/sibling-repos.txt` document its specific
  wiring; port headers carry the driving/driven label and the adapter list inline.
- The same hexagon discipline (core / ports / adapters) is applied to the
  synthetic-data branch of the stack in `sinew-vrdance/pose_distill`.
