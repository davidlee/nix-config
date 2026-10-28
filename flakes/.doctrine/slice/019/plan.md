# Implementation Plan SL-019: TypeSafe Jev behind the LLM gateway

Prose companion to `plan.toml`. Narrative only — no queried data lives here
(the storage rule); the phase list, criteria, verification, and links are
authored in the TOML. Use this for the plan's rationale and sequencing.
<!-- Reference forms: `lib:reference/glossary.md` § reference forms. -->

## Overview

Four phases, following the design's change table (design.md sec-1):

```
PHASE-01 route gate ──> PHASE-02 provider + models + proxy tests ──┐
PHASE-03 CLI refuses root (independent) ───────────────────────────┼──> PHASE-04 docs, rollout, VH
```

## Sequencing & Rationale

**Gate first.** The route gate is the security boundary, and the only
change testable without LiteLLM (the recording-app unit tests in
`gateway-test`). Landing it first means PHASE-02's through-proxy tests
exercise the final gate rather than one about to change. ISS-020's
operator fix already supplies sec-4's canonical replay headers; PHASE-01
adds per-route fields, `/v1/systemone` and the zstd decode on top, and
folds the header rule in only if that fix has not landed.

**Provider and models with their proxy tests.** The provider entry, the
four models and the fake upstream change together: a model without its
provider fails the build, and the through-proxy cases (auth, model scope,
credential, accounting, parser agreement) need all three. The parser
agreement case belongs here, not in PHASE-01: the defect is in LiteLLM's
parser, which only the real proxy reproduces.

**The CLI change stands alone.** `is_root` touches `llm-gateway` and
`keystore-test` only; it can run in any order before rollout. It precedes
PHASE-04 because the rollout issues the screwtape key without sudo.

**Docs and rollout last.** README describes what shipped; rollout needs the
TypeSafe 1Password item (ASM-002) and ends in the one human-verified check.
SPEC-001's revision is reconcile's, not a phase's (design sec-8).

## Notes

- PHASE-02: the test's credential fixture writes a dummy credential for
  every baked provider (`gateway-test:88-94`), so `typesafe` gets one
  without new setup; `test_the_baked_PROVIDERS_are_the_production_configs`
  checks the new provider is baked.
- The packaged price for Jev (4.2e-8 per input token) is research.md's
  observation for LiteLLM 1.106.2. PHASE-02's spend assertion should read
  the price from the packaged map, not a literal: a LiteLLM bump that
  reprices Jev then leaves the test true, and `price-check.py` still fails
  the build if Jev loses its price.
