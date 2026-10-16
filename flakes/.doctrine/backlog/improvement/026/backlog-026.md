# IMP-026: lazygit belongs to dev.scm, not the home base

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

lazygit is installed twice: as a bare package in the `dev.scm` feature
(`features/dev.nix`) and through `programs.lazygit` (with its nushell
integration) in the home base (`modules/home/nushell.nix:73`). Both resolve to
the same drv, so nothing collides, but the base criterion (DEC-031: what any
home needs to function) does not cover a git TUI, and deselecting `dev.scm`
leaves lazygit installed (SL-008 PHASE-04 `scm-off` control, RV-018).

Fix: move `programs.lazygit` (enable + `enableNushellIntegration`) into
`dev.scm`'s homeManager half and drop the bare `lazygit` entry. The base then
loses lazygit — a behaviour change, so gate it: Sleipnir `home-path-links`
identical with dev.scm selected; `scm-off` then shows no `bin/lazygit`.
