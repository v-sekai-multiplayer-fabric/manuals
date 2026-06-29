---
title: Ghostly partial-body presence avatar from ANNY via SOMA-X
date: 2026-06-06
status: superseded by 20260611-loot-action-core-loop-mvp-vertical-slice.md
tier: proof of concept
decision-makers: K. S. Ernest (iFire) Lee
---

## Context and Problem Statement

The [presence marker decision](20260606-presence-marker-representation.md) calls for
a vague ghostly humanoid that conveys position and heading. CHI-298
proposed fitting personas with SOMA (unifying parametric body models) and ANNY; the
Linear issue is canceled, but the concept is the natural basis for that ghostly
form. We track only three points (head and two hands), so a full posed body is
under-constrained and risks the uncanny valley. Which body model do we use, and how
much of the body do we show?

## Decision Drivers

- A recognizable human form from three tracked points.
- Stay clear of the uncanny valley in a head-mounted display.
- Render only what we track; do not fabricate an untracked lower body.
- Scale to a Discord call, and retarget personas across body models.

## Considered Options

- Full parametric body (ANNY) posed from three points via IK.
- Partial body: head plus bust (shoulders and chest) plus hands, ghostly shading.
- Floating head and hand markers only (the prior markers).

## Decision Outcome

Chosen option: "Partial body — head, bust, and hands", built from ANNY and
retargeted through SOMA-X, shaded as a translucent ghostly form.

Can we show only hands and a bust? Yes. ANNY is one parametric mesh with a unified
topology plus a dedicated hand model, and SOMA-X offers level-of-detail meshes and a
shared rig, so we render a masked subset — head, shoulders and chest, hands — and
drop the lower-body vertices we cannot track.

Recommendations:

- Default to a translucent, stylized ghost bust and hands driven by the 3-point
  pose; the head carries heading; the hands keep a distinct shape.
- Keep it abstract. Translucency and stylization sit on the safe side of the
  uncanny valley, and fluid motion helps more than facial realism.
- Use SOMA-X as the pivot so personas authored in ANNY, MHR, or SMPL-X retarget to
  one rig.
- Licensing: ANNY core is Apache 2.0 and its MPFB2 data is CC0, while the SMPL-X
  topology is non-commercial. Ship on ANNY or MHR topology; keep SMPL-X to research.
- Keep the orb debug mode from the marker decision.

Uncanny-valley guidance, ranked for this use case:

1. Schwind et al. on the uncanny valley in HCI [@schwind2018uncanny] — abstraction
   helps, and the valley is deeper in HMDs.
2. Aspects of visual avatar appearance [@avatarappearance2021] — realistic reads as
   more human yet uncannier; abstraction is the safer default.
3. Stein and Ohler, the uncanny valley of mind [@stein2017uncanny] — limit
   mind-attribution cues such as faked eyes or expressions.
4. Mori's original uncanny valley [@mori2012uncanny] — motion shifts the curve.

### Consequences

- Good: a human, heading-bearing presence that stays uncanny-safe and renders only
  the tracked region.
- Good: SOMA-X retargets personas across body models.
- Bad: it adds a body model and a Python/Warp persona pipeline.
- Bad: the SMPL-X topology license rules that topology out for shipping.

### Confirmation

A translucent bust-and-hands avatar renders from the 3-point pose at call scale and
reads as human without tripping the uncanny valley in an HMD.

## More Information

Refines the [presence marker decision](20260606-presence-marker-representation.md)
and revives [CHI-298](https://linear.app/chibifire/issue/CHI-298/use-soma-and-anny-to-fit-concepts-to-personas).
Models: [ANNY](https://github.com/naver/anny), [SOMA-X](https://github.com/NVlabs/SOMA-X).
