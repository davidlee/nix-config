{ 
  pkgs,
  username,
  ...
}: {
  hardware = {
    steam-hardware.enable = true;
  };

  programs = {
    steam = {
      enable = true;
      gamescopeSession.enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true; 
      protontricks.enable = true;
    };

    gamemode.enable = true;
    gamescope.enable = true;
  };

  services = {
    sunshine = {
      enable = true; 
      openFirewall = true;
      autoStart = true;
      capSysAdmin = true;
    };
    udev.packages = [ pkgs.game-devices-udev-rules ];
  };

  home-manager.users.${username} = {
    home.packages = with pkgs; [
      steamcmd
      steam-tui
      steamcmd
      steam-run
      bottles
      lutris
      heroic
      mangohud
      protontricks
      protonup-qt
      gamemode
      gamescope
      moonlight-qt
      sunshine
    ];
  };
}
