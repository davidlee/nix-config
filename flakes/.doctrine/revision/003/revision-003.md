# REV REV-003 — reconcile SL-004

Revision — a pending revise-intent against authored governance/spec
truth. The structured `[[change]]` payload lives in the sister `revision-NNN.toml`;
this prose companion carries the rationale and the free-text before/after excerpts
for prose-body section edits.

## Rationale

<!-- Why this revision: what authored truth needs to change and why, the scope of
     the staged delta, and (for ADR/POL/STD/prose rows) the before/after excerpts
     the structured payload only labels. Seeded at `revision new`. -->

Brings ADR-003 and ADR-001 to the shape SL-004 built: Home Manager is
standalone on darwin too (DEC-017, IMP-012). Driven by RV-010 F-8
(§ Reconciliation Brief); planned in SL-004 design sec-6. Wording agreed by
the user in session (2026-10-15, "agreed").

## Reconcile narrative (SL-004)

ADR-003 (primary) [RV-010 F-8]:
- §Context: "On Linux, Home Manager is a standalone configuration" → "On
  every platform"; "Darwin embeds Home Manager as a darwin module" dropped;
  note that darwin embedded HM until SL-004 (DEC-017).
- §Decision: separate system (NixOS or nix-darwin) and Home Manager
  evaluations on every platform; "Darwin continues to embed Home Manager"
  and the REV-001 paragraph on darwin's embedded HM receiving no projection
  dropped (no longer true; IMP-012 resolved).
- §Verification: `darwinConfigurations` beside `nixosConfigurations`.

ADR-001 [RV-010 F-8]:
- §Context: "three independent evaluations per host: NixOS, standalone Home
  Manager (Linux), and nix-darwin (with Home Manager embedded)" →
  evaluations of three kinds (NixOS, nix-darwin, standalone Home Manager on
  either platform); a host has one system evaluation and, with
  `home = true`, one home evaluation.

