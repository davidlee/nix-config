# CHR-021: Backfill a product spec (PRD) for the LLM gateway

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

SPEC-001 (LLM gateway tech spec) was written with no product parent; its
"why" is one paragraph in its Overview. A product spec (`/spec-product`)
would own the intent the tech spec realises:

- the problem: agents in jails need models without holding provider keys;
- who it serves: jailed agents, editor clients (gptel, minuet), satan,
  oubliette rooms;
- success measures: no provider key in any client, spend per client
  visible and capped, adding a model or provider is a one-entry change;
- out of scope: subscription logins (IMP-035), anything off this host.

Then set SPEC-001's `descends_from` to it and cut its Overview's why down to
a citation. If IDE-008 moves the gateway to oubliette, write it there.
