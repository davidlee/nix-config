{pkgs, ...}: {
  programs = {
    steam = {
      gamescopeSession.enable = true;
    };

    gamemode = {
      enable = true;
      settings = {
        general.inhibit_screensaver = 1;
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
  };

  services = {
    udev.packages = [pkgs.game-devices-udev-rules];

    # BRONKEN - try me later eh? remind me to build a cool auto-gc'd overlay thing
    #
    # ananicy = {
    #   enable = true;
    #   package = pkgs.ananicy-cpp;
    #   rulesProvider = pkgs.ananicy-cpp;
    #   extraRules = [
    #     {
    #       "name" = "gamescope";
    #       "nice" = -20;
    #     }
    #   ];
    # };
  };

  environment = {
    systemPackages = with pkgs; [
      gamemode
      gamescope
      gamescope-wsi
    ];
  };
}
