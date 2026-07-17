{
  pkgs,
  inputs,
  ...
}: {
  system.stateVersion = "24.11";
  nixpkgs.config.allowUnfree = true;

  nix = {
    settings = {
      trusted-users = ["root" "@wheel"];
      experimental-features = ["nix-command" "flakes"];
      max-jobs = 4;
      cores = 4;
      auto-optimise-store = true;
      substituters = [
        "https://cache.nixos.org"
        "https://cosmic.cachix.org/"
        "https://nixpkgs-wayland.cachix.org"
        "https://walker.cachix.org"
        "https://walker-git.cachix.org"
        "https://hyprland.cachix.org"
        "https://cache.nixos-cuda.org"
        "https://niri.cachix.org"
        "https://vicinae.cachix.org"
        "https://noctalia.cachix.org"
        "https://cache.numtide.com"
      ];

      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE="
        "walker.cachix.org-1:fG8q+uAaMqhsMxWjwvk0IMb4mFPFLqHjuvfwQxE4oJM="
        "walker-git.cachix.org-1:vmC0ocfPWh0S/vRAQGtChuiZBTAe4wiKDeyyXM0/7pM="
        "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
        "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
        "vicinae.cachix.org-1:1kDrfienkGHPYbkpNj1mWTr7Fm1+zcenzgTizIcI3oc="
        "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
        "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
      ];
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  # Cap nix-daemon memory so heavy builds (rust links) don't swap out the desktop
  # and freeze the cursor. Soft limit: kernel reclaims nix-daemon's own pages and
  # throttles its allocations past 40G rather than OOM-killing the build. Leaves
  # ~20G for sway + apps + page cache. Bump if builds thrash inside the cgroup.
  systemd.services.nix-daemon.serviceConfig.MemoryHigh = "40G";

  # WORKAROUND (remove after nixpkgs bump past 2026-05-27): crates.io rate-limits
  # and 403s the curl/* User-Agent on /api/v1/.../download, used by importCargoLock
  # (e.g. pub/zerostack.nix). fetchurl honours NIX_CURL_FLAGS (impureEnvVars); a
  # non-curl UA gets the 302 to static.crates.io, which curl then follows.
  # Upstream fix nixpkgs#524985 (commit c0a89c3) switches the registry to
  # static.crates.io directly — once the nixpkgs pin includes it, delete this line.
  # fetchurl is content-addressed, so workaround and fix share crate store paths.
  systemd.services.nix-daemon.environment.NIX_CURL_FLAGS = "-A nixpkgs-fetchurl";

  environment.systemPackages = with pkgs; [
    # root needs git on PATH: `nixos-rebuild` runs nix as root, and the
    # git+file flake fetch of a dirty tree shells out to `git`. The user's
    # full git lives in home.packages, which root can't see. (gitMinimal
    # is enough for nix's fetch; no gui/svn needed.)
    gitMinimal
    inputs.nix-search-tv.packages.x86_64-linux.default
    alejandra
    appimage-run
    flatpak
    cachix
    comma
    devenv
    manix
    nh
    nil
    nix-bash-completions
    nix-bisect
    nix-btm
    nixd
    nix-deploy
    nix-derivation
    nix-diff
    nix-direnv
    nix-du
    nixfmt
    nix-forecast
    nix-health
    nix-index
    nix-inspect
    nix-janitor
    nix-melt
    nix-output-monitor
    nix-search-cli
    nix-search-tv
    nix-top
    nix-tree
    nvd
    pkg-config
    sd-switch
    npins
  ];
}
