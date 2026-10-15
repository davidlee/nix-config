# REV REV-005 — reconcile SL-006

Revision — a pending revise-intent against authored governance/spec
truth. The structured `[[change]]` payload lives in the sister `revision-NNN.toml`;
this prose companion carries the rationale and the free-text before/after excerpts
for prose-body section edits.

## Rationale

<!-- Why this revision: what authored truth needs to change and why, the scope of
     the staged delta, and (for ADR/POL/STD/prose rows) the before/after excerpts
     the structured payload only labels. Seeded at `revision new`. -->

SL-006 retired the legacy flag machinery (`modules/features.nix`, the
`features` specialArg, import-gating). Two accepted ADRs still describe the
coexistence period. User agreed the wording at reconcile (2026-10-16).

### ADR-001 D2

Before: "While the legacy flags remain, features sit beside them under
`feature`, and no path is both a flag and a feature: the resolver refuses an
option declared at a feature's path."

After: "The resolver refuses any other outer option declared at a feature's
path. (Until SL-006 retired them, the legacy flags sat beside features under
this rule.)"

### ADR-001, closing paragraph of Decision

Before: "`specialArgs.features` carries the legacy flags only. The feature
selection is removed from it, so downstream modules cannot inspect the
selection to make composition decisions."

After: "The feature selection is not passed to downstream modules (SL-006
retired `specialArgs.features`, which carried the legacy flags), so
downstream modules cannot inspect the selection to make composition
decisions."

### ADR-005 D1

Before: "… for its supported platforms. Transitional: while the legacy flags
coexist, this binds only features in the tree (`features/`)."

After: "… for its supported platforms." (no flags remain, so the rule binds
every feature).

## Reconcile narrative

- [RV-014 F-2]: ADR-001 D2 and its specialArgs paragraph, and ADR-005 D1's
  transitional clause, described the flag/feature coexistence SL-006 ended.
  Amended to the post-flag state, keeping the history in one parenthetical.
