---
title: Quest 3 frame floor as the MVP performance gate
date: 2026-06-11
status: deprecated
tier: baseline
decision-makers: K. S. Ernest (iFire) Lee
---

## Context and Problem Statement

The MVP runs on three candidate targets: the Meta Quest 3, the Valve Steam Frame, and the Steam Deck. The team needs one binding performance gate. Quest 3 stereo VR on the Adreno 740 is the hardest of the three, and the dev fleet holds one Quest 3, two Steam Decks, squad PCVR rigs, and an RTX 4090 workstation.

## Decision Outcome

Chosen option: take the standalone Quest 3 build at 90 Hz with a 72 Hz floor as the single hard gate, and land the Steam Frame and the Steam Deck after the gate, because hitting the hardest target guarantees the easier two while the reverse does not hold.

Daily iteration runs flatscreen on the Decks and the workstation, and VR iteration runs the Quest 3 tethered over Link, but the sign-off is the standalone Quest 3 build, because Link offloads rendering to the host and hides the Adreno cost.

## Consequences

- The budgets size for the Quest 3, so the later targets inherit headroom.
- A four-player Field room fits its geometry, four avatars, and props under roughly 500,000 visible triangles and 200 draw calls per eye.
- The standalone build is the only truth; a scene that runs over Link can still blow the standalone budget.

## Confirmation

The full loop holds 72 Hz on a standalone Quest 3 build with real content.
