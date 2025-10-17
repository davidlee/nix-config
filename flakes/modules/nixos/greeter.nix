{inputs, ...}: {
  flake.nixosModules.greeter = {
    pkgs,
    lib,
    config,
    ...
  }: {
    environment.systemPackages = with pkgs; [
      greetd
      tuigreet
    ];

    #
    # greetd
    #
    systemd.services.greetd.serviceConfig = {
      Type = "idle";
      StandardInput = "tty";
      StandardOutput = "tty";
      StandardError = "journal"; # Without this errors will spam on screen
      # Without these bootlogs will spam on screen
      TTYReset = true;
      TTYVHangup = true;
      TTYVTDisallocate = true;
    };

    console = {
      earlySetup = true;
      enable = true;
    };

    services = {
      greetd = {
        enable = true;
        settings = {
          default_session = let
            tuigreet = "${lib.getExe pkgs.tuigreet}";
            baseSessionsDir = "${config.services.displayManager.sessionData.desktops}";
            xSessions = "${baseSessionsDir}/share/xsessions";
            waylandSessions = "${baseSessionsDir}/share/wayland-sessions";
            theme = "'border=magenta;text=cyan;prompt=green;time=red;action=green;button=white;container=black;input=red'";
            tuigreetOptions = [
              "--cmd sway"
              "--remember"
              "--remember-session"
              "--sessions ${waylandSessions}:${xSessions}"
              "--xsession-wrapper startx /usr/bin/env"
              "--time"
              "--theme ${theme}"
            ];
            flags = lib.concatStringsSep " " tuigreetOptions;
          in {
            command = "${tuigreet} ${flags}";
            user = "greeter";
          };
        };
      };
    };
  };
}
