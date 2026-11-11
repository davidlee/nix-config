# Transient-breakage probes (DEC-053, DEC-055, DEC-056): one record per
# workaround that waits on upstream. A probe applies nothing. The fix itself
# stays local, beside its consumer (DEC-016, DEC-053); the probe names it in
# `sites`, so it can be found and reverted.
#
# `workarounds/check [pin]` (run by `just update-system`, `just update-home`
# and `just workarounds-check`) asks cache.nixos.org for each probe's store
# path: cached means the build failure is gone, and the check prints
# `candidate: remove <sites>`. ./probes.nix validates the records.
#
#   attr     path in the pin's package set (a nixpkgs attribute name)
#   pin      flake input: "nixpkgs" | "nixpkgs-home"
#   system   the system the workaround is for
#   issue    the backlog item that tracks it (ISS-/IMP-/CHR-/RSK-/IDE-NNN)
#   reason   why it exists
#   sites    every file to revert, repo-relative
#   signal   optional; "manual": never probed (a runtime bug, or an unfree
#            package, which is never cached), only listed for a check by hand
[
  {
    attr = ["killall"]; # getName: shell_cmds
    pin = "nixpkgs-home";
    system = "aarch64-darwin";
    issue = "CHR-016";
    reason = "skipped by choice while uncached (SL-008 PHASE-07 VH-1)";
    sites = ["features/platform-skips.nix"];
  }
  {
    attr = ["yed"]; # getName: yEd
    pin = "nixpkgs-home";
    system = "aarch64-darwin";
    issue = "CHR-016";
    reason = "unfree, never on cache.nixos.org; check Mac build time";
    sites = ["features/platform-skips.nix"];
    signal = "manual";
  }
  {
    attr = ["linuxPackages_latest" "v4l2loopback"]; # boot.kernelPackages (modules/nixos/kernel.nix): keep in step
    pin = "nixpkgs";
    system = "x86_64-linux";
    issue = "ISS-017";
    reason = "0.15.4 output carries depmod's index on kernel 7.3; the modules tree conflicts";
    sites = ["features/desktop/core/v4l2loopback.nix"];
    # cached either way: the package builds; the conflict is downstream
    signal = "manual";
  }
  {
    attr = ["static-web-server"];
    pin = "nixpkgs";
    system = "x86_64-linux";
    issue = "ISS-028";
    reason = "2.44.1 fails cargoSetupHook's system-lib mode (zstd, libgit2)";
    sites = ["features/services.nix"];
  }
  {
    attr = ["xq"];
    pin = "nixpkgs-home";
    system = "x86_64-linux";
    issue = "ISS-028";
    reason = "0.5.0 fails cargoSetupHook's system-lib mode (oniguruma)";
    sites = ["features/data.nix"];
  }
  {
    attr = ["felix-fm"];
    pin = "nixpkgs-home";
    system = "x86_64-linux";
    issue = "ISS-028";
    reason = "2.16.1's libgit2-sys 0.17 needs libgit2 < 1.9; nixpkgs has 1.9.7";
    sites = ["features/files.nix"];
  }
  {
    attr = ["oha"];
    pin = "nixpkgs-home";
    system = "x86_64-linux";
    issue = "ISS-028";
    reason = "1.16.0 fails cargoSetupHook's system-lib mode (aws-lc-sys)";
    sites = ["features/net.nix"];
  }
  {
    attr = ["viddy"];
    pin = "nixpkgs-home";
    system = "x86_64-linux";
    issue = "ISS-028";
    reason = "fails cargoSetupHook's system-lib mode (libsqlite3-sys)";
    sites = ["features/dev.nix"];
  }
  {
    attr = ["tui-journal"];
    pin = "nixpkgs-home";
    system = "x86_64-linux";
    issue = "ISS-028";
    reason = "fails cargoSetupHook's system-lib mode (libsqlite3-sys)";
    sites = ["features/notes.nix"];
  }
  {
    attr = ["leaf-markdown-viewer"];
    pin = "nixpkgs-home";
    system = "x86_64-linux";
    issue = "ISS-028";
    reason = "fails cargoSetupHook's system-lib mode (onig_sys)";
    sites = ["features/docs.nix"];
  }
  {
    attr = ["russ"];
    pin = "nixpkgs-home";
    system = "x86_64-linux";
    issue = "ISS-028";
    reason = "fails cargoSetupHook's system-lib mode (libsqlite3-sys)";
    sites = ["features/comms.nix"];
  }
  {
    attr = ["rustdesk-flutter"];
    pin = "nixpkgs";
    system = "x86_64-linux";
    issue = "ISS-028";
    reason = "1.5.0 fails cargoSetupHook's system-lib mode (libsodium-sys)";
    sites = ["modules/nixos/rustdesk.nix"];
  }
]
