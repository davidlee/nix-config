_: let
  sleepTimes = ["23:20" "00:00" "00:30"]; # 23:20 is 5 min after user warning at 23:15
  wakeTime = "07:00";
in {
  systemd = {
    services.snooze-suspend = {
      description = "Nightly suspend";
      script = ''
        if [ -f /tmp/idle-inhibitor-active ]; then
          echo "Idle inhibitor active, skipping suspend" >&2
          exit 0
        fi
        exec /run/current-system/sw/bin/systemctl suspend
      '';
      serviceConfig.Type = "oneshot";
    };

    timers.snooze-suspend = {
      description = "Nightly suspend";
      wantedBy = ["timers.target"];
      timerConfig = {
        OnCalendar = map (t: "*-*-* ${t}") sleepTimes;
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
}
