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
    nixosModules.flatpak
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
    nixosModules.radeon
    nixosModules.network
    nixosModules.wayland
    nixosModules.sway
    nixosModules.office
    nixosModules.apps
    nixosModules.ai
    nixosModules.build
    nixosModules.terminals
    nixosModules._1password
    nixosModules.wayland-packages
    nixosModules.xdg
    nixosModules.x11
    nixosModules.keyring
    nixosModules.pipewire
    # nixosModules.virtualisation
    # nixosModules.kmscon
    # nixosModules.microcode

    # shared:
    nixosModules.fileutils
    nixosModules.build
    nixosModules.scm
    nixosModules.gfx
    nixosModules.pkg
    nixosModules.net
    nixosModules.search
    nixosModules.sec
    nixosModules.shell
    nixosModules.supervisors
    nixosModules.text
    nixosModules.tui
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
