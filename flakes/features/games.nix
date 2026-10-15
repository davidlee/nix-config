# Games features, in projection order. Shape: README § Feature tree.
[
  {
    name = "steam";
    nixos = {pkgs, ...}: {
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

          package = pkgs.steam.override {
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
        };

        # Merged into the base set in programs.nix. Verified games requirements —
        # unpatched game binaries dlopen these.
        nix-ld.libraries = with pkgs; [
          libxt
          libxmu
          libogg
          libvorbis
          SDL
          SDL2_image
          glew_1_10
          libidn
          tbb
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
          # lutris
          # heroic
          # bottles

          # actual game things
          # blightmud
        ];
      };
    };
  }

  {
    name = "gamescope";
    # gamescopeSession is a steam option.
    requires = ["games.steam"];
    nixos = {
      pkgs,
      username,
      ...
    }: {
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
            "-e" # steam integration
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

      users.groups.gamemode.members = [username];
    };
  }

  {
    name = "mangohud";
    homeManager = _: {
      programs = {
        # lutris.enable = true;
        mangohud.enable = true;
      };
    };
  }
]
