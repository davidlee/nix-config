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
    nixosModules.ai

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
    ../../modules/shared-pkg.nix

    ../../nixos/options.nix
    ../../nixos/boot.nix
    ../../nixos/accounts.nix
    ../../nixos/env.nix
    ../../nixos/nix.nix
    ../../nixos/lib.nix
    ../../nixos/network.nix
    ../../nixos/serve.nix
    ../../nixos/virtualisation.nix
    ../../nixos/wayland.nix
    ../../nixos/sway.nix
    # ../../nixos/kde.nix
    ../../nixos/dev.nix
    ../../nixos/lang.nix
    ../../nixos/media.nix
    ../../nixos/packages.nix
    ../../nixos/sysmon.nix
    ../../nixos/util.nix
    ../../nixos/keeb.nix
    ../../nixos/apps.nix
    ../../nixos/browsers.nix
    ../../nixos/editors.nix
    ../../nixos/radeon.nix
    ../../nixos/games.nix
    ../../nixos/fonts.nix
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
