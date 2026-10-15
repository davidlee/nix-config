# Review RV-002 — code-review of SL-001

Adversarial-review ledger. Structured findings live in the sister
ledger toml; this prose companion carries the reviewer's framing.

## Brief

<!-- Pre-reading + lines of attack: what this review is probing, the invariants
     it must hold the subject to, and where the bodies are likely buried. Seeded
     at `review new`; the reviewer fills it before raising findings. -->

Subject: SL-001 implementation, commits 84d77e11, da8e70d8, d19a1d45
(`git diff bf2eb570..d19a1d45 -- flakes/`). External raiser: Codex
(gpt-6-sol), read-only; Claude verifies each candidate against the code
before raising.

Invariants (design sec-3, sec-4): resolver is a pure function of
`{tree, classes, modules}`; never forces or applies an unselected class
value; projection in index order; every failure throws so nothing is
readable; one shared selection per host; `flags` hides the selection;
coverage is off every switch path and outside `just drvs`.

Lines of attack:
- naming and cohesion in `features.nix` (e.g. `selected` used twice)
- test strength: do tests fail informatively, and do they guard the real
  risks (forcing, ordering, home-only failure), or only shapes?
- error-message quality for a host author hitting a failed check
- `hosts.nix` factory signature and `configure` helper: coupling, clarity
- coverage target: anything that makes it misleading or brittle
- README accuracy against the code; bloat
- pattern fitness for later migrations (MULTIHOST S3–S6)

## Synthesis

- **Overall**: acceptable → solid after repairs (b4f42cf2).
- **Synopsis**: The resolver followed the design sketch and held its central
  invariants: unselected values are never forced, order follows the index, and
  enforcement covers home-only builds. No blocker. The real gap was
  validation at the edges. A descriptor key typo silently dropped a feature
  half (F-1, major), and dotted names aborted uncatchably (F-2). Both are now
  structural errors, with every structural error named (F-5). These three go
  beyond design sec-3, by user assent, and are noted in the slice notes for
  reconcile. Failure tests now carry passing twins, so each proves its own
  check (F-4). The README overclaim is corrected (F-3), coverage shares the
  drvs pin (F-6), and a naming overlap is gone (F-7). Standing risk: `tryEval`
  still cannot assert message text, so message wording is checked by eye.
  Derivations stayed identical to the EN-2 baseline throughout.
- **Haiku**: A typo in the key / half a feature slipped away / now the tree
  says no.
