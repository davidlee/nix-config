{...}: {
  flake.nixosModules.util = {pkgs, ...}: {
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

      ## files / find
      fsearch
      plocate

      ## converters
      pandoc

      ## disk & file io
      mmtui # mount manager

      ## PDF
      tdf

      # ## download / backup
      backintime

      # ## docs, notes, productivity
      zeal

      ## text utils
      cicero-tui # unicode
      gtt

      ## text readers, pagers
      fltrdr
      circumflex

      ## audio
      alsa-utils
      pipewire
      wireplumber

      ## cli general
      mprocs # parallel command runner
      tray-tui # systray

      ## system utils
      isd # systemd
      lazyjournal # logs & containers
      systemctl-tui

      ## clock
      tty-clock

      # rust
      crates-tui

      # bluetooth
      bluetui
      bluetuith

      ## crypto
      # libcryptui

      ## frivolity
      fortune
      cmatrix
      nms
      openrgb-with-all-plugins
    ];
  };
}
