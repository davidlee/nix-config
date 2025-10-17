{...}: {
  flake.homeModules.Sleipnir = {
    username,
    pkgs,
    self,
    ...
  }: {
    imports = [
      ../../home/zsh.nix
      ../../home/programs.nix
      self.homeModules.nvim-plugins
      self.homeModules.nvim
    ];

    home = {
      inherit username;
      homeDirectory = "/home/${username}";
      stateVersion = "24.11";
    };

    services.systembus-notify.enable = true; # notify-send from systemd

    systemd.user = {
      # Nicely reload system units when changing configs
      startServices = "sd-switch";
      services = {
        break-remind = {
          Unit.Description = "Reminder to take welfare breaks.";

          Service = {
            Type = "oneshot";
            Persistent = false;
            RemainAfterExit = false;
            # Restart = "always";
            # RuntimeMaxSec = 30;
            ExecStart = toString (
              pkgs.writeShellScript "break-remind.sh" ''
                TMP=/tmp/break-remind.notify-id

                if [ ! -f $TMP ]; then
                    NID=$(${pkgs.libnotify}/bin/notify-send -p "initial message")
                    echo $NID > $TMP
                fi
                NID=$(cat $TMP)

                ICON=/run/current-system/sw/share/icons/breeze-dark/emblems/16/emblem-information.svg
                TEXT="Get out of your chair. Rest your eyes."

                ${pkgs.libnotify}/bin/notify-send -r "$NID" -i "$ICON" "$TEXT" -u low
                exit 0
              ''
            );
          };
        };
      };

      timers = {
        break-remind = {
          Unit.Description = "Take short breaks";
          Install.WantedBy = ["timers.target"];
          Timer = {
            Unit = "break-remind.service";
            # OnCalendar = "*-*-* *:*:00/15";
            OnActiveSec = 60; # Initial delay after timer starts
            OnUnitInactiveSec = 900; # Repeat every 15 minutes (900 seconds)
            # wantedBy = ["timers.target"];
            # Persistent = true; # Run missed executions if system was off
            AccuracySec = "1s";
          };
        };
      };
    };

    programs.home-manager.enable = true;
  };
}
