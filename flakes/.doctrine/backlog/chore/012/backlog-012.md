# CHR-012: One file per feature: fold snooze's halves inline; tighten ADR-002 D3

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

SL-001 split snooze into `features/session/snooze/{default,nixos,home}.nix`
(SL-001 design § Layout). ADR-002 allows this (D3 "Granularity": a feature
with assets may be a directory), but it works against the ADR's own reason
for the tree, "a capability's system and home halves live together". It
also leaves a five-line descriptor wrapper, the kind of file D3 warns
against.

1. **Fold snooze.** `features/session/snooze/default.nix` holds the
   descriptor with both modules inline
   (`{ nixos = {...}: {…}; homeManager = {...}: {…}; }`). `bin/` stays
   beside it. Unselected modules are still never evaluated (ADR-002 D4),
   because an inline function is not called unless projected. Ownership
   move only: `just drvs` identical (`mem.pattern.flakes.drv-gate`).
   Update the header comments and README § Snooze / Feature tree, which
   name `home.nix` and `nixos.nix`.
2. **Tighten ADR-002 D3** by revision: one file per feature, with its
   halves inline; a directory only to hold assets or tests beside that
   file.

SL-002 (capsule) already follows the tighter rule (one NixOS-only file).
Do this before the next slice (RFC-001 W2) so W2 starts from the settled
shape.
