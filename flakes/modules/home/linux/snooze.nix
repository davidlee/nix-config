# The user half of snooze: the bedtime nag, and the suspend it eventually
# performs. The system half (modules/nixos/snooze.nix) is only the RTC wake
# alarm now — `systemctl suspend` needs no privilege from an active session,
# so the decision to suspend belongs next to the person being asked.
#
# The escalation, and why dismissing the toast is not an escape, are in the
# script. `snooze-nag-test` alongside it holds that behaviour without a
# display.
#
# Smoke:
#   systemctl --user list-timers snooze-nag.timer
#   journalctl --user -u snooze-nag -f
#   SNOOZE_GRANTS='2 1' SNOOZE_UNIT=1 SNOOZE_ABSENT=1 snooze-nag
_: let
  bedtime = "23:20";
in {
  # A plain script in ~/.local/bin, as spotify-alarm is: readable, editable
  # and dry-runnable without going through nix.
  home.file.".local/bin/snooze-nag" = {
    source = ./bin/snooze-nag;
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
}
