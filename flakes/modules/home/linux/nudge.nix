# nudge — nudge toward Emacs (and the daily journal) from panopticon's
# window history. A notification button runs the umbriel raise script.
#
# The scripts run live from this checkout, not the store: tuning rules and
# thresholds (./nudge/nudge.nu) needs no switch.
#
#   nu ~/flakes/modules/home/linux/nudge/nudge-test.nu      tests
#   nu ~/flakes/modules/home/linux/nudge/main.nu --explain  current assessment
#   journalctl --user -u nudge
{
  config,
  pkgs,
  ...
}: {
  systemd.user.services.nudge = {
    Unit.Description = "nudge — toward Emacs and the journal";
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.nushell}/bin/nu ${config.home.homeDirectory}/flakes/modules/home/linux/nudge/main.nu";
      # The notification blocks until clicked; while it does, the timer
      # can't start a second run.
      TimeoutStartSec = "5min";
    };
  };

  systemd.user.timers.nudge = {
    Unit.Description = "nudge — check every 10 minutes";
    Install.WantedBy = ["timers.target"];
    Timer.OnCalendar = "*:0/10";
  };
}
