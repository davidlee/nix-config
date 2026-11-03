# Review RV-046 — design of SL-023

Adversarial-review ledger. Structured findings live in the sister
ledger toml; this prose companion carries the reviewer's framing.

## Brief

Reviewer: `codex`, acting as raiser (the existing ledger declares the generic
`raiser`/`responder` labels). This brief is populated under the review workflow
in `lib:reference/review-ledger.md` section 2; findings and conclusion use the
Doctrine CLI. No other authored file is changed by this pass.

Subject: SL-023 scope and materialised design, its notes/research, predecessor
SL-022, and DEC-107 through DEC-119. Authority: accepted ADR-001 through ADR-005,
SPEC-002 and POL-001. Accepted user choices are constraints; challenge their
migration, placement and verification rather than reopening settled preferences.

Lines of attack: single ownership and dependency direction across host facts,
jail library, consumer and producer; mandatory product-build coupling and reload
claims; runtime mount order and PATH versus baked invocations; host/darwin and
absent-checkout fallback; dispatch versus interactive confinement; GC roots and
form approvals; cross-repo fleet ordering and preservation of unmigrated users;
whether verification can exercise the promised final state at its stated point.

Evidence is source inspection and read-only commands. Inspect the actual
consumer, direnv/form helpers, agents posture, host configuration, Doctrine
producer/installer/dispatch script and fleet target. Runtime consequences are
explicitly labelled inference. No Nix evaluation/build, direnv reload, jail or
form execution, installation, activation, Git mutation or external configuration
write is performed: those would exceed this pass's ledger-only write boundary.
