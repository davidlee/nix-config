# REV REV-006 — ADR-002 D3: a big record may import modules of its own

Revision — a pending revise-intent against authored governance/spec
truth. The structured `[[change]]` payload lives in the sister `revision-NNN.toml`;
this prose companion carries the rationale and the free-text before/after excerpts
for prose-body section edits.

## Rationale

<!-- Why this revision: what authored truth needs to change and why, the scope of
     the staged delta, and (for ADR/POL/STD/prose rows) the before/after excerpts
     the structured payload only labels. Seeded at `revision new`. -->

SL-007's `desktop.core` record (DEC-026) gathers eight whole modules, about
400 lines. Inlining them into one file buries the structure and loses each
module's `git mv` history. RV-015 F-6 found that ADR-002 D3 does not admit a
record importing modules of its own. The user chose to revise D3 rather than
inline the modules or call them assets (2026-10-16).

D3, before:

> … The own file holds the whole record. Assets sit near their feature. …

D3, after:

> … The own file holds the whole record. A record too big for one file may
> import modules of its own from `features/<area>/<name>/`, listed explicitly
> in the half that uses them (D7: no discovery); they belong to that record
> and to no other. Assets sit near their feature. …

Unchanged: one record per feature, halves together, never split by platform;
D4's exclusion boundary holds, because an unselected record's `imports` are
inside a class value and never forced.

Applied in the SL-007 phase that adds `desktop.core`, together with the README
"own file" rule, so the two never disagree.
