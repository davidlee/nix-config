_: {
  flake.nixosModules.gamescope = {pkgs, ...}: {
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
      systemPackages = with pkgs; [
        gamemode
        gamescope
      ];
    };
  };
}
