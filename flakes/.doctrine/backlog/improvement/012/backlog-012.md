# IMP-012: darwin: standalone Home Manager, symmetric with Linux

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

Linux runs Home Manager standalone (`homeConfigurations."david@<host>"`, own
pin `nixpkgs-home`, `home-switch` without sudo). Darwin embeds it as a
nix-darwin module (`darwin/default.nix:22-31`, `useGlobalPkgs`), one switch.
ADR-003 keeps the asymmetry but gives reasons only for the Linux side (fast
userland fixes without a system rebuild; aggressive home pin), and those
apply equally to the Mac.

Making darwin standalone would let `mkHome` serve both platforms, so darwin
gets `homeManager` projection with no embedded-HM hook. That is the hook
DEC-001 defers.

It is a behaviour change: darwin's activation and outputs change. It needs
its own slice and an ADR-003 amendment. Raised during SL-001 design,
2026-10-15.
