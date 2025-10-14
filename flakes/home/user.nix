# Home manager configuration (non-flake)
# TODO move to ~/nix-config
{
  username,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./zsh.nix
    ./nvim.nix
    ./programs.nix
  ];

  home = {
    username = "${username}";
    homeDirectory = "/home/${username}";
    stateVersion = "24.11";
  };

  programs.home-manager.enable = true;
  services.systembus-notify.enable = true;

  systemd.user = {
    startServices = "sd-switch";
    services = {
      break-remind = {
        Unit.Description = "Reminder to take welfare breaks.";

        Service = {
          Type = "oneshot";
          Persistent = false;
          RemainAfterExit = false;
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
          OnActiveSec = 60;
          OnUnitInactiveSec = 900;
          AccuracySec = "1s";
        };
      };
    };
  };
}
