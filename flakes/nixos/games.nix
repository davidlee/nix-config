{ 
  pkgs,
  username,
  ...
}: {
  hardware = {
    steam-hardware.enable = true;
    xone.enable = true;
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

    gamemode = {
      enable = true;
      settings = {
        general.inhibit_screensaver = 0;
      };
    };
    
    gamescope = {
      enable = true;
      capSysNice = false; # see ananicy
      args = [
        "-w 1920" # game dimensions
        "-h 1440"
        "-f" # fullscreen
        # "-e" # steam integration
        "--force-grab-cursor"
      ];
    };

    appimage = {
      enable = true;
      binfmt = true;
    };
  };

  ## home manager for the things only it supports
  home-manager.users.${username} = {
    programs = {
      lutris.enable = true;
      mangohud.enable = true;  
    };
  };

  services = {
    sunshine = {
      enable = true; 
      openFirewall = true;
      capSysAdmin = true;
      # capSysNice = true;
      autoStart = false;
    };
    udev.packages = [ pkgs.game-devices-udev-rules ];

    ananicy = {
      enable = true;
      package = pkgs.ananicy-cpp;
      rulesProvider = pkgs.ananicy-cpp;
      extraRules = [
        {
          "name" = "gamescope";
          "nice" = -20;
        }
      ];
    };
  };

  environment = {
    sessionVariables = {
      # use it for everything
      # MANGOHUD = 1;
    };

    systemPackages = with pkgs; [
      # steam 
      steamcmd
      steam-tui
      steamcmd

      # other runners
      lutris
      heroic
      bottles

      # compositor stuff
      gamemode
      gamescope
      mangohud
    
      # remote sessions
      moonlight-qt
      sunshine

      # wine - try only 32 bit
      wine
      winePackages.staging
      # winePackages
    
      # compatibility - extras
      winetricks
      protontricks
      protonup-qt
    
      # wine-staging
      # wineWowPackages.stagingFull # support both 32 and 64 bit
      # wine-wayland # not sure if we _want_ to have wayland support, it doesn't seem ready yet
    ];
  };

}
