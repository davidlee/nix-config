# Implementation Plan SL-014: OpenRouter and Fireworks behind the LLM gateway

Prose companion to `plan.toml`. Narrative only — no queried data lives here
(the storage rule); the phase list, criteria, verification, and links are
authored in the TOML. Use this for the plan's rationale and sequencing.
<!-- Reference forms: `lib:reference/glossary.md` § reference forms. -->

## Overview

Five phases, each ending green. Design: `design.md` (locked, run revision 34).

```
PHASE-01 pi optional ──> PHASE-02 providers, params, price rule ──┬──> PHASE-03 body guard ──┐
  (agents/)                (proxy.nix, gateway.nix, fake OpenRouter)│                         ├──> PHASE-05 docs, rollout
                                                                    └──> PHASE-04 models verb ┘
```

## Sequencing & Rationale

- **PHASE-01 first.** The new served models have no pi block; until pi is
  optional, adding them fails evaluation. It touches only `agents/`.
- **PHASE-02** adds providers, `params`, the price rule and the models in
  one step: the price rule is only exercised by models that use it, and
  the fake OpenRouter it introduces proves the cost path (DEC-068).
- **PHASE-03 after PHASE-02.** The body guard's end-to-end twins need the
  fake OpenRouter to show that a refused body sends nothing upstream. The
  guard is the security boundary for every model, deepseek-flash included,
  so it lands before any rollout.
- **PHASE-04** is independent of PHASE-03 (keystore and CLI only); it
  follows PHASE-02 so the served set it validates against is final.
- **PHASE-05** is the only phase with live effects: credentials, switch,
  probes. Nothing goes live before the guard exists.

## Notes

- Client fixture bodies (PHASE-03 EN-2): eca and pi are already on the
  gateway, so their bodies can be captured; gptel's and minuet's are
  reconstructed from their source until emacs:SL-015 moves them over. A
  field missing from the allow-list surfaces there, not in production.
- **No `system-switch` from PHASE-02 until PHASE-05's rollout.** Once the
  tree serves openrouter and fireworks, the unit needs their credentials;
  without them systemd refuses the whole unit (DEC-048), DeepSeek included.
  A switch for other work in that window takes the gateway down until
  PHASE-05 steps 1–3 run. `home-switch` is unaffected.
- PHASE-05 edits README § LLM gateway, which SL-013 also edits; rebase on
  whatever SL-013 has landed.
