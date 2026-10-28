# REV REV-013 — reconcile SL-019

Revision — a pending revise-intent against authored governance/spec
truth. The structured `[[change]]` payload lives in the sister `revision-NNN.toml`;
this prose companion carries the rationale and the free-text before/after excerpts
for prose-body section edits.

## Rationale

<!-- Why this revision: what authored truth needs to change and why, the scope of
     the staged delta, and (for ADR/POL/STD/prose rows) the before/after excerpts
     the structured payload only labels. Seeded at `revision new`. -->

SL-019 served TypeSafe's Jev through the gateway (IMP-054). SPEC-001 and
three of its requirements still describe the gateway before it: one route
family, one global field list, no body decoding, no root refusal. RV-042
F-1 (verified) lists the drift. The code is the truth; this revision brings
the spec to it.

### SPEC-001

- Posture line: "as shipped by SL-011, SL-013 and SL-014" → add SL-019.
- Overview diagram: client line adds TypeSafe systemone; route gate line
  reads "route on the list? body decoded, fields on the route's list?
  size ≤ 16 MiB?".
- § Client contract, Routes: add `POST /v1/systemone`; `/v1/decisions` and
  `/decisions` are 404, since LiteLLM would fetch remote image URLs there
  (DEC-092).
- § Client contract, Body: per-route lists (`ROUTES`: `CHAT_FIELDS`,
  `SYSTEMONE_FIELDS`, DEC-087) replace `ALLOWED_FIELDS`; systemone's list is
  `model`, `state`, `questions`, `assets`; `typesafe-danger-zone-*` headers
  pass through (DEC-090).
- § Client contract, new Encoding paragraph (DEC-088): absent, `identity` or
  `zstd`; anything else 415 (other codings, chains, repeats, empty
  elements); zstd one complete frame (400) of at most 16 MiB decoded (413);
  every admitted body reaches LiteLLM decoded, as `application/json`.
- § Client contract, Model names: the four `typesafe/jev-*` names, on
  `/v1/systemone` only; TypeSafe SDK: zstd works, `models.list()` and
  multipart image assets do not (DEC-089).
- § Client contract, Refusals: 415 row; 400 adds zstd frame/decode; 413
  "sent or decoded".
- § Responsibilities: serve systemone beside chat completions.
- § Mechanism, Request path: decode and canonical replay (ISS-020).
- § Mechanism, Providers: names the four providers; Jev priced from the
  packaged map.
- § Mechanism, Admin CLI: refuses root, exit 2 (DEC-091).
- § Decisions: add DEC-084, DEC-085 (served models), DEC-087, DEC-088,
  DEC-089, DEC-090, DEC-092 (wire contract), DEC-091 (store, auth).

### REQ-001 (FR-001)

Title "Only the chat-completions and model-listing routes are served" →
"Only the chat-completions, systemone and model-listing routes are served".
Statement adds POST /v1/systemone. New criterion: POST /v1/decisions and
/decisions get the 404.

### REQ-002 (FR-002)

Title → "Request bodies carry only their route's allow-listed top-level
fields". Statement: per route (chat: the chat list; systemone: model, state,
questions, assets); Content-Encoding absent, identity or zstd, else 415; a
zstd body one complete frame of at most 16 MiB decoded. New criteria:
systemone refuses messages and api_base, chat refuses state; gzip 415; a
zstd bomb 413.

### REQ-008 (FR-008)

New criterion: run as root, every command exits 2 before doing anything.

## Reconcile narrative

- [RV-042 F-1]: SPEC-001 and REQ-001/002/008 amended to the gateway as built
  by SL-019 (PHASE-01..03), including the ALLOWED_FIELDS → ROUTES change that
  design sec-8 omitted.
