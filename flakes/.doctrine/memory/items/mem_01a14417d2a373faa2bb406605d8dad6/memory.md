Extends [[mem.pattern.flakes.drv-gate]].
- `.manpath` in home-files carries `home-path`'s store hash, so any reorder of home imports moves it even when every link is identical. Proof of order-only: diff with store hashes masked is empty (DEC: SL-008 design § Phases and verification). IMP-019 would normalise it in the probe.
- A relative `path:` override resolves against the git root (`$HOME`), not ~/flakes: always build override paths from `justfile_directory()`.
- A drift-free baseline from a `git archive` copy needs `flake := "path:" + justfile_directory()` in the copy's justfile.
- On the Mac: the flake must be referenced as `path:` (bare dotfiles repo defeats git discovery; `bin/gate-probe` does this on Darwin), system mode is NixOS-only (`just probe` skips it on macOS), and the link-map code needs GNU tools: `nix shell nixpkgs#findutils nixpkgs#coreutils -c just probe <dir>`.
- Comparing link maps across generations: join on relpath with package names (hash and version stripped); a raw diff is all store-path noise.
