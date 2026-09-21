# The system half of snooze: the RTC wake alarm, and nothing else.
#
# Suspending is the user half's job (modules/home/linux/snooze.nix) — an
# active session may `systemctl suspend` unprivileged, and the decision now
# follows an answer to a prompt rather than a clock. Waking cannot move: only
# a system timer may set `WakeSystem`.
_: let
  wakeTime = "07:00";
in {
  systemd = {
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
