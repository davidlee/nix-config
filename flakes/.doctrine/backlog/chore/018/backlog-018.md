# CHR-018: Author a tech spec for the LLM gateway

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

The gateway's durable contract is spread over the README (§ LLM gateway),
about twenty decisions (DEC-046..051, DEC-058..074) and three slices (SL-011,
SL-013, SL-014). No spec owns it, so each new client or consumer cites
whichever decision it finds. QUE-004 in satan was one result: the reasoning
wire convention had no home until DEC-074.

A technical spec (`/spec-tech`, after `/spec-coverage-assessment`) would
own:

- the client wire contract: routes, the body allow-list (DEC-073), reasoning
  effort (DEC-074), model naming (DEC-069);
- keys, budgets and the ledger (DEC-046, DEC-050, DEC-051, DEC-071);
- providers, credentials and cost sources (DEC-048, DEC-064, DEC-067, DEC-068);
- the relay and socket perimeter (DEC-047);
- the boundary with `agents/` (DEC-059, DEC-063).

The DECs stay as its rationale; the README shrinks to operations.

Sequence with IDE-008: if the gateway moves to oubliette, the spec moves
with it. Writing the spec first defines the interface that move has to
preserve, and settles IDE-008's "coupling to settle first" (what the gateway
owns vs what the jails own).

## Progress (2026-10-18)

- Spec coverage census: `.doctrine/state/coverage-map-llm-gateway.md`
  (runtime, not tracked). Result: no specs in the repo; one container spec.
- SPEC-001 drafted (retrospective, status draft), root placement, no PRD.
  The client contract leads; FR-001..008 and NF-001..003 (REQ-001..011,
  pending).
- Remaining: user review; shrink README § LLM gateway to operations and
  point it at SPEC-001; then resolve.
- GPT review (2026-10-18, /tmp/spec-001-review.md): all five findings
  verified and integrated: budget is a safety net on recorded spend; key
  exposure split into stored / run time / client; allow-list enumerated;
  fallbacks are a 400 (model gate's fallback check is defence in depth);
  streaming and retry behaviour stated, unverified parts labelled.
  REQ-002, 004, 005, 009, 010 restated. Open sibling: DEC-051's "bounded
  overshoot" wording overclaims the same way.
- Accepted by the user (2026-10-18); SPEC-001 status active. README
  § LLM gateway trimmed to operations and links SPEC-001; DEC-074's
  consequence and satan QUE-004's answer now cite SPEC-001 § Client
  contract. DEC-051 overshoot wording left for the user to rule on.
