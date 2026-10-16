{
  inputs,
  lib,
  pkgs,
  ...
}: {
  system.stateVersion = "24.11"; # the release this host was first installed with
  services.displayManager.defaultSession = "niri"; # preselected at the greeter

  # Sleipnir-only package fixes.
  nixpkgs.overlays = with inputs.self.overlays; [
    llama-prism
    whisper-rocm
    click-threading-fix
  ];

  imports = [
    ./hardware-configuration.nix
    ./machine.nix

    ../../modules/nixos # the base (DEC-027)
    ./dns.nix
    ./oom.nix

    # parked — these do NOT evaluate; repair before re-enabling. Deliberately
    # not features: selecting one says "flip me", which would be a lie here.
    # ../../modules/nixos/hyprland.nix   (hyprlandPlugins.hyprexpo missing)
    # ../../modules/nixos/kmscon.nix     (services.kmscon.fonts removed upstream)
  ];

  # gai.conf: prefer IPv4 (README § Prefer IPv4).
  # Prefer IPv4 in getaddrinfo source/dest selection (RFC 6724 default
  # prefers v6). ISP v6 egress has been intermittently dead — the router
  # still advertises a v6 default + hands out a global prefix, so apps dial
  # the dead v6 first and stall ~3s per attempt (wedged bun install in a nix
  # FOD). Interface-agnostic and self-healing: when v6 egress recovers, apps
  # still work, just preferring v4. mkForce overrides the stock gai.conf.
  environment.etc."gai.conf".text = lib.mkForce ''
    reload no
    precedence ::ffff:0:0/96  100
  '';

  # wheel may run rtcwake without a password: ~/.local/bin/snooze suspends
  # until a set wake time with `sudo rtcwake -m mem -s …`.
  # ORDER IS SIGNIFICANT: sudoers is last-match-wins
  security.sudo.extraRules = [
    {
      groups = ["wheel"];
      commands = [
        {
          command = "${pkgs.util-linux}/bin/rtcwake";
          options = ["NOPASSWD" "SETENV"];
        }
        {
          command = "/run/current-system/sw/bin/rtcwake";
          options = ["NOPASSWD" "SETENV"];
        }
      ];
    }
  ];
}
