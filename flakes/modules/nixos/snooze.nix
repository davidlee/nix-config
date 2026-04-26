_: {
  flake.nixosModules.snooze = _: let
    sleepTime = "23:20"; # 5 min after user warning at 23:15
    wakeTime = "07:00";
  in {
    systemd = {
      services.snooze-suspend = {
        description = "Nightly suspend";
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "/run/current-system/sw/bin/systemctl suspend";
        };
      };

      timers.snooze-suspend = {
        description = "Nightly suspend";
        wantedBy = ["timers.target"];
        timerConfig = {
          OnCalendar = "*-*-* ${sleepTime}";
          AccuracySec = "1s";
        };
      };

      services.snooze-wake = {
        description = "RTC wake target (no-op)";
        serviceConfig.Type = "oneshot";
        serviceConfig.ExecStart = "/run/current-system/sw/bin/true";
      };

      timers.snooze-wake = {
        description = "RTC wake alarm";
        wantedBy = ["timers.target"];
        timerConfig = {
          OnCalendar = "*-*-* ${wakeTime}";
          WakeSystem = true;
          AccuracySec = "1s";
        };
      };
    };
  };
}
