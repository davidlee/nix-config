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

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  systemd.user.services = {
    shutdown-nightly = {
      Unit = {
        Description = "Sleepy time soon.";
      };
      Service = {
        Type = "oneshot";
        ExecStart = toString (
          pkgs.writeShellScript "nightly-shutdown.sh" ''
            set -eou pipefail
            ${pkgs.libnotify}/bin/notify-send -i /run/current-system/sw/share/icons/breeze-dark/emblems/16/emblem-important.svg "The system is going down soon."
            ${pkgs.systemd}/bin/shutdown -h "23:00"
          ''
        );
      };
      Install.WantedBy = ["timers.target"];
    };

    break-remind = {
      Unit = {
        Description = "Reminder to take welfare breaks.";
      };
      Service = {
        Type = "oneshot";
        ExecStart = toString (
          pkgs.writeShellScript "break-remind.sh" ''
            set -eou pipefail
            ${pkgs.libnotify}/bin/notify-send -i /run/current-system/sw/share/icons/breeze-dark/emblems/16/emblem-information.svg "Take a short break: stretch, drink water, rest your eyes." -A OK
          ''
        );
      };
      Install.WantedBy = ["timers.target"];
    };
  };

  systemd.user.timers = {
    shutdown-nightly = {
      Unit.Description = "Sleipnir is going to sleep soon.";
      Timer = {
        Unit = "shutdown-nightly";
        OnCalendar = "10:50..10:59";
      };
    };

    break-remind = {
      Unit.Description = "Take short breaks";
      Timer = {
        Unit = "break-remind";
        OnCalendar = "*:0/30";
      };
    };
  };

  programs.home-manager.enable = true;
}
