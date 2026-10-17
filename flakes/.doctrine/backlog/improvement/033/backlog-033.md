# IMP-033: Silence Lix lock-diff noise in update-* recipes

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

update-system / update-home run nix commands with `--no-write-lock-file` and
local overrides; Lix prints "Updated input …" lock-diff lines for every
overridden input, which reads as if the lock changed. Suppress or filter them.
SL-012 PHASE-04; RV-027 F-6.
