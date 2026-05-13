_: {
  flake.homeModules.office = {pkgs, ...}: {
    home.packages = with pkgs; [
      beeper
      signal-desktop
      signal-cli
      qrencode # for signal-cli

      discord
      element-desktop
      zotero
      thunderbird-latest
      slack
      zoom-us
    ];
  };
}
