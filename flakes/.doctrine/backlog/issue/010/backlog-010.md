# ISS-010: Every lock write re-resolves emacs/emacs-overlay (unpinned nested url override)

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

`flake.nix` overrides the emacs input's nested `emacs-overlay` with an
unpinned URL (`inputs.emacs-overlay.url = "github:nix-community/emacs-overlay"`).
Any lock-writing command (`nix flake lock`, `nix flake update <anything>`,
`nix fmt`) re-resolves it to upstream HEAD whenever upstream has moved.

Evidence (2026-10-16, SL-009 PHASE-01): `nix flake update agents oubliette …`
also bumped `emacs/emacs-overlay` 3d05567 → 9e88531; a plain `nix flake lock`
on the pre-slice lock (scratch copy) did the same. CHR-008's resolution
("`nix flake lock` leaves the lock byte-identical") held only while upstream
HEAD equalled the locked rev.

Related: `mem.fact.flakes.fmt-relock` (now partly wrong), the drift note in
`mem.pattern.flakes.drv-gate`, IMP-019 (pin emacs-overlay in the probe).

Possible directions: drop the top-level override and let the emacs flake's
own lock pin it; or bump it deliberately with `nix flake update emacs/emacs-overlay`
and accept the re-lock as the update path.
