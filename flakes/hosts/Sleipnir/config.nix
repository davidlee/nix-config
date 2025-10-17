{
  pkgs,
  self,
  ...
}: {
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

  imports = with self; [
    ./hardware-configuration.nix
    nixosModules.env
    nixosModules.nix
    nixosModules.ai
    nixosModules.lib
    nixosModules.browsers
    nixosModules.editors
    nixosModules.fonts
    nixosModules.keyboard
    nixosModules.webserver
    nixosModules.postgresql
    nixosModules.devtools
    nixosModules.mpd
    nixosModules.media
    nixosModules.sysmon
    nixosModules.graphics
    nixosModules.programs
    nixosModules.util
    nixosModules.security
    nixosModules.user
    nixosModules.games
    nixosModules.boot
    nixosModules.greeter
    nixosModules.virtualisation
    nixosModules.radeon
    # nixosModules.kmscon
    # nixosModules.microcode

    ../../modules_legacy/shared-build.nix
    ../../modules_legacy/shared-editors.nix
    ../../modules_legacy/shared-fileutil.nix
    ../../modules_legacy/shared-gfx.nix
    ../../modules_legacy/shared-keeb.nix
    ../../modules_legacy/shared-net.nix
    ../../modules_legacy/shared-packages.nix
    ../../modules_legacy/shared-pkg.nix
    ../../modules_legacy/shared-scm.nix
    ../../modules_legacy/shared-search.nix
    ../../modules_legacy/shared-security.nix
    ../../modules_legacy/shared-shell.nix
    ../../modules_legacy/shared-supervisors.nix
    ../../modules_legacy/shared-text.nix
    ../../modules_legacy/shared-tui.nix

    ../../nixos/network.nix
    ../../nixos/wayland.nix
    ../../nixos/sway.nix
    ../../nixos/apps.nix
  ];

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
