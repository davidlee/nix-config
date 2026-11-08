# REV REV-022 — ADR-005 D3: coverage selections may be computed

## Rationale

D3 required coverage targets to be handwritten. With a host's off features
listed by hand, turning a feature off on the host meant editing the target as
well, and a target that forced a feature on with a plain `true` conflicted with
the host's plain `false` (the cause of commit 504ebca5, which flipped three
targets to `false` and left them covering nothing).

A computed target is not the "every feature on" target the Context rejects: it
selects only the features the host leaves off, plus their prerequisites, never
the host's own selection. The remaining hazard, two exclusive features both
off, is handled by giving an exclusive feature its own handwritten target and
leaving it out of the computed one.

User direction (2026-11-09 session): "it's not an 'everything on' target if
it's the complement of sleipnir's packages, is it?", then "yes" to amending D3.

## D3 before

> 3. Targets are a small handwritten set, not a generated matrix. They are
>    outside the switch path: a broken off feature never blocks building or
>    switching a host.

## D3 after

> 3. Targets are few, not a generated matrix. A target's selection may be
>    computed (REV-022): the features a host leaves off, with their
>    prerequisites, so turning a feature off needs no edit to stay covered. No
>    host's choice may break a target: a feature exclusive with another gets
>    its own handwritten target and is left out of the computed one. Targets
>    are outside the switch path: a broken off feature never blocks building
>    or switching a host.

Implemented by: `features.nix` result `off`; `hosts.nix` `coverage."Sleipnir+off"`
and `coverage."david@Sleipnir+off"`.
