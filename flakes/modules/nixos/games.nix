_: {
  flake.nixosModules.games = {
    pkgs,
    username,
    ...
  }: {
    hardware = {
      steam-hardware.enable = true;
      # xpadneo.enable = true; # broken
    };

    programs = {
      steam = {
        enable = true;
        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = true;
        localNetworkGameTransfers.openFirewall = true;
        protontricks.enable = true;
      };
    };

    services = {
      udev.packages = [pkgs.game-devices-udev-rules];
    };

    home-manager.users.${username} = {
      programs = {
        lutris.enable = true;
      };
    };

    environment = {
      systemPackages = with pkgs; [
        # steam
        steamcmd
        steam-tui
        steamcmd

        # wine
        wine
        winePackages.staging
        winetricks
        protontricks
        protonup-qt

        # minecraft
        prismlauncher

        # other runners
        lutris
        heroic
        bottles

        # actual game things
        # blightmud
      ];
    };
  };
}
