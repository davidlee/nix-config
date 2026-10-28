# Review RV-042 — reconciliation of SL-019

Adversarial-review ledger. Structured findings live in the sister
ledger toml; this prose companion carries the reviewer's framing.

## Brief

<!-- Pre-reading + lines of attack: what this review is probing, the invariants
     it must hold the subject to, and where the bodies are likely buried. Seeded
     at `review new`; the reviewer fills it before raising findings. -->

Conformance audit of SL-019 (TypeSafe Jev behind the LLM gateway), primary
tree, implementation range e4a88373..761e0165 (PHASE-01 10559b4c, PHASE-02
bd26aef4, PHASE-03 26ef21fa, PHASE-04 653e7d43 + rollout 761e0165), plus the
ISS-020 hotfix 504ebca5. That commit also carries operator changes outside the
slice (flake.lock, hosts.nix, hosts/Sleipnir/features.nix,
modules/nixos/kernel.nix); they are not audited here.

Lines of attack:
- Route gate (design sec-3, sec-4): ROUTES is the only route list; systemone's
  field list is closed; decode bounds (window_log_max 24, max_length) and the
  refusal table; canonical replay on every admitted POST.
- Provider and models (sec-2): no reportsCost, no pi block, upstream model name
  bare, spend from input tokens.
- CLI (sec-5): root refused before any argument parsing.
- Tests vs sec-6: every listed case has a test; gate green.
- README vs code vs SPEC-001; the notes' Autonomy log decisions and deferrals.
- Path conformance (`slice conformance`), judged by agent under ISS-005.

## Synthesis

**Closure story.** The code matches the design. `gateway_hooks.py` replaces
ALLOWED_ROUTES/ALLOWED_FIELDS with one ROUTES map; POST bodies are decoded
(zstd only, one frame, window and output both capped at 16 MiB) before the
per-route field check and replayed as `application/json`. The `typesafe`
provider and four Jev models are declared as designed; the CLI refuses root
first. Every sec-6 case has a test (RouteGateUnitTest, JevTest,
ParserAgreementTest, RootRefused); `just test` is green. VH-1 passed live and
the operator accepted it.

No code defect was found. The findings are documentation drift (F-1 SPEC-001,
F-2 DEC-084, F-3 design sec-4), evidence strength (F-4), and bookkeeping (F-6
docstring, F-7 delta registry; both fixed during the audit). F-8 is a red
formatter check on a file outside the slice (CHR-026).

**Standing risks.**
- The TypeSafe JS SDK's own zstd bodies and its unsupported paths
  (`models.list()`, multipart images) are verified from SDK source, not a
  live SDK call (F-4). screwtape:SL-004 is the first real SDK client.
- Request headers that LiteLLM turns into request parameters are not covered
  by the field allow-list (notes § Further review). Predates SL-019, applies to
  every route; not checked.
- `doctrine check gate` stays red until CHR-026 lands.

**Tradeoffs accepted.**
- Empty content-encoding elements are refused (415), stricter than RFC 9110
  allows (F-3); documented rather than relaxed.
- VH-1 on hand-encoded zstd and the provider cost header rather than the SDK
  and the ledger's 4-decimal display (F-4).
- One `named` helper for openrouter and typesafe model names (F-5).

## Reconciliation Brief

### Per-slice (direct edit)
- design.md sec-4 (F-3): after "every occurrence, split on commas, trimmed,
  lowercased, as one list", state that empty elements are kept, so `zstd,`
  and an empty header value fall to "any other list" → 415.

### Governance/spec (REV)
- SPEC-001 (F-1), REV modify:
  - § Client contract, routes: add POST /v1/systemone (fields model, state,
    questions, assets); /v1/decisions and /decisions are 404 (DEC-092).
  - § Body and FR-002's REQ text: ALLOWED_FIELDS → per-route lists via ROUTES
    (CHAT_FIELDS, SYSTEMONE_FIELDS; DEC-087).
  - Refusals table: 415 content-encoding not supported; 400 zstd not one
    complete frame / does not decode; 413 on decoded size.
  - § Request path: zstd decode before the field check; admitted body
    replayed as application/json with canonical content-length, no
    content-encoding or transfer-encoding.
  - § Model names / Providers: `typesafe` provider (packaged price map); the
    four typesafe/jev-* models, no pi block.
  - TypeSafe SDK: `models.list()` and multipart image assets unsupported
    (DEC-089).
  - § Admin CLI: refuses root, exit 2 (DEC-091).
- DEC-084 (F-2): amend the choice text to name POST /v1/systemone only,
  citing DEC-092.
- Backlog closures (PHASE-04 EX-3): IMP-054, ISS-015, ISS-020 → done.
