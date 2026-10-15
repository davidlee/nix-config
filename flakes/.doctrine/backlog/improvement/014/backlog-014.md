# IMP-014: Draupnir: nix settings and caches under installer-managed Lix

The Mac (Draupnir) sets `nix.enable = false` (`darwin/default.nix`), so the
installer-managed Lix owns `/etc/nix/nix.conf` and nix-darwin ignores every
`nix.*` setting (some throw when read: nix-darwin `modules/nix/default.nix`
143-165). Consequences: `darwin/nix-core.nix` (substituters incl.
nix-community and cache.lix.systems, experimental-features, gc) is imported
nowhere and cannot simply be re-imported; experimental features come from the
Lix installer's own `nix.conf`; the Mac lacks Sleipnir's cache list, so
updates are slow.

**Why it is this way** (commit `1b87f392`, "fix: darwin reinstall",
2026-10-02, replacing an earlier comment): nix-darwin-managed Lix
(`nix.package = pkgs.lixPackageSets.stable.lix`) failed to build from source
after the macOS 27 / Xcode CLT 27 upgrade — ld64-956.6 rejects
`-z,noexecstack` ("Compiler clang++ cannot compile programs";
tpoechtrager/cctools-port#193, conda-forge/cctools-and-ld64-feedstock#112) —
and cache.lix.systems had no aarch64-darwin substitute. The reinstall
switched to installer-managed Lix.

Routes (user leans to a, 2026-10-15, "a) seems best but iirc there was a
reason"):

- **a.** `nix.enable = true`, `nix.package` = Lix, settings shared with
  Sleipnir. Blocked until a Lix substitute exists for aarch64-darwin or the
  ld64 break is fixed — check cache.lix.systems / nixpkgs first.
- **b.** keep installer Lix; add settings through a file its `nix.conf`
  includes (inspect the Mac's `/etc/nix/nix.conf`).
- **c.** user-level `~/.config/nix/nix.conf` via Home Manager `nix.settings`;
  substituters only honoured for a trusted user.

Sharing caches with Sleipnir means lifting the substituter list out of
`modules/nixos/nix.nix` into something both platforms import. Resolve the
fate of `darwin/nix-core.nix` here. Raised during SL-004 design (SL-004
deliberately leaves both alone). Related: SL-004 deletes the darwin
direnv `doCheck` overlay, which defeated cache.nixos.org for direnv + mise.
