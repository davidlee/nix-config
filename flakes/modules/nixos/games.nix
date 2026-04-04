_: {
  flake.nixosModules.games = {pkgs, ...}: {
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

    programs.steam.package = pkgs.steam.override {
      extraPkgs = pkgs':
        with pkgs'; [
          libxcursor
          libxi
          libxinerama
          libxscrnsaver
          libpng
          libpulseaudio
          libvorbis
          stdenv.cc.cc.lib # Provides libstdc++.so.6
          libkrb5
          keyutils
          # Add other libraries as needed
        ];
    };

    services = {
      udev.packages = [pkgs.game-devices-udev-rules];
    };

    environment = {
      systemPackages = with pkgs; [
        # steam
        steamcmd
        steam-tui
        steamcmd
        steam-run

        # wine
        wine
        winePackages.staging
        winetricks
        protontricks
        protonup-qt
        # proton-ge-bin

        # minecraft
        # prismlauncher

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
