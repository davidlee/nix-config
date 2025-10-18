_: {
  flake.nixosModules.util = {pkgs, ...}: {
    programs = {
      dconf.enable = true;
      gnome-disks.enable = true;
    };

    services = {
      devmon.enable = true;
      gvfs.enable = true;
      udisks2.enable = true;
      sysprof.enable = true;
      printing.enable = true;
    };

    hardware = {
      logitech.wireless.enable = true;
      opentabletdriver.enable = true;
      i2c.enable = true;
    };

    environment.systemPackages = with pkgs; [
      ## disk / io
      hdparm
      smartmontools
      udiskie

      ## network / http
      iptraf-ng
      nethogs
      nmon
      vnstat

      # ## download / backup
      backintime

      ## disk & file io
      mmtui # mount manager

      ## cli general
      mprocs # parallel command runner
      tray-tui # systray

      ## system utils
      isd # systemd
      lazyjournal # logs & containers
      systemctl-tui

      ## search
      fsearch
      plocate

      ## help
      tealdeer
      zeal
      pinfo

      ### text utils
      cicero-tui # unicode
      gtt

      ## text readers, pagers
      fltrdr
      circumflex
    ];
  };
}
