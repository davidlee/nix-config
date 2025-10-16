# NixOS configuration for Sleipnir (non-flake)
{
  config,
  pkgs,
  lib,
  ...
}: let
  sources = import ../../npins;

  # Import stable nixpkgs
  stable = import sources.nix-stable {
    system = "x86_64-linux";
    config.allowUnfree = true;
  };

  hmPath = sources.home-manager.outPath;
  nixSearchPath = sources."nix-search-tv".outPath;

  getFlakeOutputs = source:
    (builtins.getFlake ("path:" + builtins.toString source.outPath)).outputs;

  inputs = {
    home-manager = {
      nixosModules.home-manager = import (hmPath + "/nixos"); # module path
      packages.${system}.default = import (hmPath + "/home-manager/home-manager.nix") {
        inherit pkgs lib;
      }; # or however you prefer to expose this package
    };

    nix-search-tv = {
      packages.${system}.default =
        pkgs.callPackage (nixSearchPath + "/default.nix") {};
    };
    helix = getFlakeOutputs sources.helix;
    # home-manager = getFlakeOutputs sources.home-manager;
    # "nix-search-tv" = getFlakeOutputs sources."nix-search-tv";
    "rust-overlay" = getFlakeOutputs sources."rust-overlay";
    ucodenix = getFlakeOutputs sources.ucodenix;
    "neovim-nightly-overlay" = getFlakeOutputs sources."neovim-nightly-overlay";
    "zig-overlay" = getFlakeOutputs sources."zig-overlay";
    zls = getFlakeOutputs sources.zls;
  };

  # Home Manager module from pinned flake outputs
  homeManagerModule = inputs.home-manager.nixosModules.home-manager;

  # System configuration
  hostname = "Sleipnir";
  username = "david";
  system = "x86_64-linux";
in {
  _module.args = {
    inherit pkgs lib username hostname system stable sources inputs;
  };
  # Lix overlay
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
  nix.channel.enable = false;

  imports = [
    ./hardware-configuration.nix

    # Home manager module
    homeManagerModule

    ../../modules/shared-packages.nix
    ../../modules/shared-tui.nix
    ../../modules/shared-shell.nix
    ../../modules/shared-scm.nix
    ../../modules/shared-editors.nix
    ../../modules/shared-text.nix
    ../../modules/shared-search.nix
    ../../modules/shared-build.nix
    ../../modules/shared-supervisors.nix
    ../../modules/shared-keeb.nix
    ../../modules/shared-sysmon.nix
    ../../modules/shared-security.nix
    ../../modules/shared-fileutil.nix
    ../../modules/shared-gfx.nix
    ../../modules/shared-net.nix

    ../../nixos/options.nix
    ../../nixos/boot.nix
    ../../nixos/accounts.nix
    ../../nixos/env.nix
    ../../nixos/nix.nix
    ../../nixos/network.nix
    ../../nixos/serve.nix
    ../../nixos/virtualisation.nix
    ../../nixos/wayland.nix
    ../../nixos/sway.nix
    ../../nixos/dev.nix
    ../../nixos/lang.nix
    ../../nixos/media.nix
    ../../nixos/packages.nix
    ../../nixos/sysmon.nix
    ../../nixos/util.nix
    ../../nixos/keeb.nix
    ../../nixos/ai.nix
    ../../nixos/apps.nix
    ../../nixos/browsers.nix
    ../../nixos/editors.nix
    ../../nixos/radeon.nix
    ../../nixos/games.nix
    ../../nixos/fonts.nix
    ../../nixos/kde.nix
  ];

  # Home manager configuration
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";

    users.${username} = import ../../home/user.nix;

    # Pass extra arguments to home-manager
    extraSpecialArgs = {
      inherit username hostname stable system sources;
    };
  };

  # enable SSD trim & improve perf
  fileSystems."/".options = ["noatime" "nodiratime" "discard"];

  services = {
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
    pavucontrol
  ];

  hardware = {
    logitech.wireless.enable = true;
    opentabletdriver.enable = true;
    i2c.enable = true;

    bluetooth = {
      enable = true;
      powerOnBoot = true;

      settings = {
        General = {
          Experimental = true;
          JustWorksRepairing = "always";
          FastConnectable = true;
          Privacy = "device";
        };
      };
    };
  };
}
