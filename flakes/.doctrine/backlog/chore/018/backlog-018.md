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
