{pkgs, ...}: {
  ## USE LIX
  nixpkgs.overlays = [
    (final: prev: {
      inherit
        (prev.lixPackageSets.stable)
        nixpkgs-review
        nix-eval-jobs
        nix-fast-build
        colmena
        ;
    })
  ];
  nix.package = pkgs.lixPackageSets.stable.lix;

  imports = [
    ./hardware-configuration.nix

    ../../modules/shared-packages.nix
    ../../modules/shared-development.nix
    ../../modules/shared-tui.nix
    ../../modules/shared-shell.nix
    ../../modules/shared-scm.nix
    ../../modules/shared-editors.nix
    ../../modules/shared-text.nix
    ../../modules/shared-search.nix
    ../../modules/shared-build.nix
    ../../modules/shared-supervisors.nix
    ../../modules/shared-keeb.nix
    ../../modules/shared-lsp.nix
    ../../modules/shared-sysmon.nix
    ../../modules/shared-security.nix
    ../../modules/shared-fileutil.nix
    ../../modules/shared-gfx.nix
    ../../modules/shared-net.nix
    ../../modules/shared-pkg.nix

    ../../nixos/options.nix
    ../../nixos/boot.nix
    ../../nixos/accounts.nix
    ../../nixos/network.nix
    ../../nixos/serve.nix
    ../../nixos/virtualisation.nix
    ../../nixos/wayland.nix
    ../../nixos/sway.nix
    ../../nixos/dev.nix
    ../../nixos/tui.nix
    ../../nixos/packages.nix
    ../../nixos/apps.nix
    ../../nixos/browsers.nix
    ../../nixos/editors.nix
    ../../nixos/radeon.nix
    ../../nixos/games.nix
    ../../nixos/fonts.nix
    ../../nixos/ai.nix

    # ../../nixos/graphics.nix
    # ../../nixos/audio.nix
    # ../../nixos/rust.nix
    # ../../modules/zig.nix
    # ../../nixos/gnome.nix
    # ../../nixos/nur.nix
    # ../../nixos/hyprland.nix
    # ../../nixos/kde.nix
    # ../../nixos/arr.nix
  ];

  system.stateVersion = "24.11";
  nixpkgs.config.allowUnfree = true;

  nix = {
    settings = {
      trusted-users = ["root" "@wheel"];
      experimental-features = ["nix-command" "flakes"];
      max-jobs = 12;
      cores = 12;
      auto-optimise-store = true;
      substituters = [
        "https://cache.nixos.org"
        "https://cosmic.cachix.org/"
        "https://nixpkgs-wayland.cachix.org"
        "https://walker.cachix.org"
        "https://walker-git.cachix.org"
        "https://hyprland.cachix.org"
      ];

      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE="
        "walker.cachix.org-1:fG8q+uAaMqhsMxWjwvk0IMb4mFPFLqHjuvfwQxE4oJM="
        "walker-git.cachix.org-1:vmC0ocfPWh0S/vRAQGtChuiZBTAe4wiKDeyyXM0/7pM="
        "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      ];
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 1w";
    };
  };

  # enable SSD trim & improve perf
  fileSystems."/".options = ["noatime" "nodiratime" "discard"];

  services = {
    # kmonad.enable = true;
    devmon.enable = true;
    gvfs.enable = true;
    udisks2.enable = true;
    sysprof.enable = true;
    blueman.enable = true;
    printing.enable = true;

    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

    locate = {
      enable = true;
      package = pkgs.plocate;
      interval = "hourly";

      prunePaths = [
        "/tmp"
        "/var/tmp"
        "/var/cache"
        "/var/lock"
        "/var/run"
        "/var/spool"
        # use nix-locate / nix-index instead to avoid polluting locate results:
        "/nix/store"
        "/nix/var/log/nix"
      ];
    };

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    pulseaudio = {
    };

    hardware.openrgb.enable = true;

    udev.packages = [pkgs.openrgb-with-all-plugins];
  };

  environment.systemPackages = with pkgs; [
    # jack2
    # libjack2
    # qjackctl
    pavucontrol
    # jack_capture
  ];

  hardware = {
    logitech.wireless.enable = true;
    opentabletdriver.enable = true;
    i2c.enable = true;

    # it's amazing bluetooth _ever_ works
    bluetooth = {
      enable = true;
      powerOnBoot = true;

      settings = {
        General = {
          Experimental = true; # battery level
          JustWorksRepairing = "always";
          FastConnectable = true;
          # Class = "0x00100";
          Privacy = "device";
        };
      };
    };
  };
}
