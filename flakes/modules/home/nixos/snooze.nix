_: {
  flake.homeModules.snooze = {pkgs, ...}: let
    sleepTime = "23:15";
    leadMinutes = 5;
  in {
    systemd.user = {
      services.snooze-warn = {
        Unit.Description = "Warn before nightly suspend";
        Service = {
          Type = "oneshot";
          ExecStart = toString (pkgs.writeShellScript "snooze-warn" ''
            ${pkgs.libnotify}/bin/notify-send -u critical \
              "Suspending in ${toString leadMinutes} minutes"
          '');
        };
      };

      timers.snooze-warn = {
        Unit.Description = "Nightly suspend warning";
        Install.WantedBy = ["timers.target"];
        Timer = {
          Unit = "snooze-warn.service";
          OnCalendar = "*-*-* ${sleepTime}";
          AccuracySec = "1s";
        };
      };
    };
  };
}
