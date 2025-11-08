_: {
  flake.nixosModules.office = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      ## productivity
      thunderbird-latest
      #evolution
      # morgen # TODO enable when electron deps fixed
      zotero
      #foliate
      onlyoffice-desktopeditors
      libreoffice
      # gnome-frog
      papers
      scribus
      zotero

      ## messaging / social
      newsflash
      discord # broken, using stable
      #stable.discord
      beeper
      signal-desktop
      slack
      zoom-us
      # rambox
      # telegram-desktop
      element-desktop
      #whatsie

      ## mind map etc
      freemind

      ## search
      recoll

      # ## docs, notes, productivity
      dnote

      ## scanner
      # naps2
      # xsane
      # kdePackages.skanlite
      # kdePackages.skanpage
    ];
  };
}
