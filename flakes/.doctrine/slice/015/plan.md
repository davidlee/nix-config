# Implementation Plan SL-015: Gateway and launch-dir options for network-isolated jails

Prose companion to `plan.toml`. Narrative only — no queried data lives here
(the storage rule); the phase list, criteria, verification, and links are
authored in the TOML. Use this for the plan's rationale and sequencing.
<!-- Reference forms: `lib:reference/glossary.md` § reference forms. -->

## Overview

Four phases, each green on its own. Gateway first because it is independent
and smallest; then the jailLib refactor that changes no launcher; then the new
behaviour on top of it; then docs and the live check, which needs the user's
`just system-switch`.

## Sequencing & Rationale

```
PHASE-01 relay listener ──┐
PHASE-02 profiles + launch dir (no launcher change) ──> PHASE-03 forwarder + socket mode
  ──> PHASE-05 env-deps opt-out + named home ──> PHASE-04 docs + live
```

- **PHASE-01** touches only the system evaluation. Nothing uses the socket
  yet, so it can land and switch at any point.
- **PHASE-02** is a refactor with one new option. Its proof is that every
  existing jail test passes unmodified: the profile table must reproduce
  today's argv exactly. Separating it keeps PHASE-03's diff about behaviour.
- **PHASE-03** needs the profile flag (PHASE-02) to decide when to wire
  the forwarder, and the client constant (PHASE-01) for its default endpoints.
  The forwarder is a pure function of `{ socket, port }` so its behaviour
  test runs real socat in the build sandbox's own netns, without bwrap (the
  sandbox has no user namespaces).
- **PHASE-04** is last because the live check needs PHASE-01 switched and
  PHASE-03 built; the READMEs describe what shipped.

## Notes

- Plan review (2026-10-20): premises re-checked against the tree (`username`
  module arg, jail.nix `defer`/`ro-bind` signatures, `failsToEvaluate`
  catches `throw`); argv order pinned in PHASE-02 EX-1; the live check names
  its ad hoc jail, since no committed jail is offline with a gateway.

- The live check's TCP-jail control is any existing gateway jail (e.g.
  `jailed-pi`).
- satan:SL-027 consumes the result; its jail changes are not in this plan.
- 2026-10-20: PHASE-05 added at the user's direction (satan:SL-027 RV-035
  F-1 env workspace-deps opt-out, F-6 named persisted home), ordered before
  PHASE-04 so the docs cover it. Order is now 01 → 02 → 03 → 05 → 04. The
  design is amended at reconcile.
- Live finding (2026-10-20): after `just system-switch` the relay socket
  unit lists the client socket but `/run/llm-gateway-client/` is absent:
  the running socket unit was not restarted. PHASE-04 must handle it
  (restart, plus docs or a restart trigger).
