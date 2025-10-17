_: {
  flake.nixosModules.office = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      ## productivity
      thunderbird-latest
      #evolution
      # morgen # TODO enable when electron deps fixed
      zotero
      #foliate
      onlyoffice-bin
      libreoffice
      # gnome-frog
      papers
      scribus

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
      # minder
      # semantik
      # vue

      ## search
      recoll

      ## scanner
      # naps2
      # xsane
      # kdePackages.skanlite
      # kdePackages.skanpage
    ];
  };
}
