# IMP-032: Expose lastGood as a flake output

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

`workarounds/last-good.nix` (lastGood) is imported by path; README § Workarounds
says so. A flake output (e.g. `lib.lastGood`) would give consumers a stable
name. SL-012 PHASE-05; RV-027 F-6.
