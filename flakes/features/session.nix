# Session features, in projection order. Shape: README § Feature tree.
[
  # Snooze: the bedtime nag, and the RTC alarm that wakes the machine again.
  #
  # The nag is the home half. It suspends the machine, eventually: an active
  # session may `systemctl suspend` unprivileged, and the decision follows an
  # answer to a prompt rather than a clock, so it belongs next to the person
  # being asked. The escalation, and why dismissing the toast is not an
  # escape, are in ./session/snooze-nag; `snooze-nag-test` beside it holds
  # that behaviour without a display.
  #
  # The wake alarm is the system half, and nothing else: only a system timer
  # may set `WakeSystem`.
  #
  # Smoke:
  #   systemctl --user list-timers snooze-nag.timer
  #   journalctl --user -u snooze-nag -f
  #   SNOOZE_GRANTS='2 1' SNOOZE_UNIT=1 SNOOZE_ABSENT=1 snooze-nag
  {
    name = "snooze";

    homeManager = _: let
      bedtime = "23:20";
    in {
      # A plain script in ~/.local/bin, as spotify-alarm is: readable, editable
      # and dry-runnable without going through nix.
      home.file.".local/bin/snooze-nag" = {
        source = ./session/snooze-nag;
        executable = true;
      };

      systemd.user = {
        services.snooze-nag = {
          Unit = {
            Description = "Bedtime nag";
            # The prompt is a toast: with no session there is nobody to show it
            # to, and nothing to keep awake.
            After = ["graphical-session.target"];
            PartOf = ["graphical-session.target"];
          };
          # Type defaults to simple, which is what this is: it runs for the rest
          # of the night, sleeping between prompts. A oneshot would be killed by
          # TimeoutStartSec long before the first snooze elapsed.
          Service.ExecStart = "%h/.local/bin/snooze-nag";
        };

        timers.snooze-nag = {
          Unit.Description = "Bedtime nag";
          Install.WantedBy = ["timers.target"];
          Timer = {
            Unit = "snooze-nag.service";
            OnCalendar = "*-*-* ${bedtime}";
            AccuracySec = "1s";
          };
        };
      };
    };

    nixos = _: let
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
    };
  }
]
