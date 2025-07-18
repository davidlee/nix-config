{
  username,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ../../home/zsh.nix
    ../../home/nvim.nix
    ../../home/programs.nix
  ];

  home = {
    username = "${username}";
    homeDirectory = "/home/${username}";
    stateVersion = "24.11";
  };

  # TODO: verify if this helps ssh agent work
  services.gnome-keyring.enable = true;
  services.systembus-notify.enable = true; # notify-send from systemd

  systemd.user = {
    # Nicely reload system units when changing configs
    startServices = "sd-switch";

    services = {
      # shutdown-nightly = {
      #   Unit.Description = "Sleepy time soon.";
      #
      #   Service = {
      #     Type = "oneshot";
      #     # RemainAfterExit = false;
      #     Restart = "always";
      #     ExecStart = toString (
      #       pkgs.writeShellScript "nightly-shutdown.sh" ''
      #         set -e
      #
      #         ${pkgs.libnotify}/bin/notify-send -i /run/current-system/sw/share/icons/breeze-dark/emblems/16/emblem-important.svg "The system is going down soon."
      #         ${pkgs.systemd}/bin/shutdown -h "23:00"
      #       ''
      #     );
      #   };
      # };

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
              ${pkgs.libnotify}/bin/notify-send -i /run/current-system/sw/share/icons/breeze-dark/emblems/16/emblem-information.svg "Take a short break: stretch, drink water, rest your eyes." -A OK
            ''
          );
        };
      };
    }; # services

    timers = {
      # shutdown-nightly = {
      #   Unit.Description = "Sleipnir is going to sleep soon.";
      #   Install.WantedBy = ["timers.target"];
      #   Timer = {
      #     Unit = "shutdown-nightly.service";
      #     OnCalendar = "10:50..10:59";
      #     wantedBy = ["timers.target"];
      #     # Persistent = false;
      #     # RuntimeMaxSec = 30;
      #     AccuracySec = "1s";
      #     Restart = "always";
      #     RemainAfterElapse = false;
      #   };
      # };

      break-remind = {
        Unit.Description = "Take short breaks";
        Install.WantedBy = ["timers.target"];
        Timer = {
          Unit = "break-remind.service";
          # OnCalendar = "*-*-* *:*:00/15";
          OnActiveSec = 60;  # Initial delay after timer starts
          OnUnitInactiveSec = 900;  # Repeat every 15 minutes (900 seconds)
          # wantedBy = ["timers.target"];
          Persistent = true;  # Run missed executions if system was off
          AccuracySec = "1s";
        };
      };
    }; # timers
  }; # systemd.users

  programs.home-manager.enable = true;
}
