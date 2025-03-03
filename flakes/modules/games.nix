
{ 
  pkgs,
  inputs,
  username,
  ...
}: {

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
      protonup-qt
      gamescope
    ];
  };

  hardware = {
    steam-hardware.enable = true;
  
    # bluetooth = {
    #   # enable = true;
    #   # powerOnBoot = true;
    # };
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
}
