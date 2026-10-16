# REV REV-008 — ADR-005 D6: a selected feature whose platforms omit the host's system is an error

Revision — a pending revise-intent against authored governance/spec
truth. The structured `[[change]]` payload lives in the sister `revision-NNN.toml`;
this prose companion carries the rationale and the free-text before/after excerpts
for prose-body section edits.

## Rationale

<!-- Why this revision: what authored truth needs to change and why, the scope of
     the staged delta, and (for ADR/POL/STD/prose rows) the before/after excerpts
     the structured payload only labels. Seeded at `revision new`. -->

DEC-030 (user, 2026-10-16) gives feature records a `platforms` key and has
the resolver refuse a selected feature whose `platforms` omit the host's
system. That refusal is a sibling of D6's "projects nothing" error, and it
settles the question D6 left open. Design: SL-008 `design.md` § Platform scope
in the resolver, § Governance. DEC-007's D6 sentence is unchanged.

D6, before:

> A selected feature that projects no module into any evaluation of its host
> is an error. How platform scope is declared (e.g. linux-only Home Manager
> features on darwin) is left open; no support metadata until needed.

D6, after:

> A selected feature that projects no module into any evaluation of its host
> is an error; so is a selected feature whose `platforms` omit the host's
> system. Platform scope is declared on the record (ADR-002 D1, DEC-030).

SL-008 design § Governance calls "no support metadata until needed"
the Neutral clause; in the accepted ADR it is the last clause of D6 itself, so
the D6 rewrite above discharges it. The Neutral section ("Building off
features is out of scope.") is unchanged. Positive bullet "… without
metadata" refers to maintenance status, not platform scope; unchanged.

Applied at SL-008 `/reconcile`, with REV-007 (ADR-002).

## Reconcile narrative

- [RV-018 F-14]: approved by the user ("accept revs", 2026-10-16). Landed by
  hand at SL-008 `/reconcile`: D6 now names the `platforms` refusal and
  points platform scope at the record (ADR-002 D1, DEC-030); its "no support
  metadata until needed" clause is discharged. Neutral and Positive unchanged.
