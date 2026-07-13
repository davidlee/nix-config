# panopticon — local desktop-behaviour capture daemon.
#
# Source: ~/dev/panopticon (path: input — switch to git+file:// once stable).
# Writes JSONL to ~/.local/state/behaviour/{raw,current}.
#
# Smoke:
#   systemctl --user status panopticon-sway
#   journalctl --user -u panopticon-sway -f
#   tail -f ~/.local/state/behaviour/raw/sway-$(date +%F).jsonl
{
  inputs,
  pkgs,
  lib,
  ...
}: let
  panopticon = inputs.panopticon.packages.${pkgs.system}.panopticon;
in {
  home.packages = [panopticon];

  systemd.user.services.panopticon-sway = {
    Unit = {
      Description = "panopticon — Sway behaviour event watcher";
      After = ["graphical-session.target"];
      PartOf = ["graphical-session.target"];
    };
    Service = {
      Type = "simple";
      ExecStart = "${lib.getExe panopticon}";
      Restart = "always";
      RestartSec = 2;
    };
    Install.WantedBy = ["graphical-session.target"];
  };

  systemd.user.services.panopticon-segmentize = {
    Unit.Description = "panopticon — derive segments + enforce retention";
    Service = {
      Type = "oneshot";
      ExecStart = "${panopticon}/bin/panopticon-segmentize";
    };
  };

  systemd.user.services.panopticon-git = {
    Unit.Description = "panopticon — host-side git-commit poller (SATAN git sensor)";
    Service = {
      Type = "oneshot";
      # Absolute store path: a --user oneshot has a thin PATH and would not
      # resolve a bare `panopticon-git`.  Defaults suffice — dev_root=~/dev,
      # state under ~/.local/state/behaviour, 7-day committer-date horizon.
      ExecStart = "${panopticon}/bin/panopticon-git";
    };
  };

  systemd.user.timers.panopticon-git = {
    # Captures commits made anywhere under ~/dev — including inside bwrap
    # jails where the post-commit hook never fires.  Idempotent: stateless
    # (repo, sha) dedup against the day-file, so re-polls are no-ops.  A
    # flock guards poller-vs-poller overlap, so a slow poll can't stack.
    Unit.Description = "panopticon — poll ~/dev git repos for new commits";
    Timer = {
      Unit = "panopticon-git.service";
      OnBootSec = "2min";
      OnUnitActiveSec = "5min";
      Persistent = true;
    };
    Install.WantedBy = ["timers.target"];
  };

  systemd.user.timers.panopticon-segmentize = {
    # Was nightly (03:30) — but SATAN's observer classifies an
    # intervention against the focus/browser SEGMENTS in the 30-min
    # window after it fired, and ticks run intraday (~30 min).  A
    # once-a-day derivation left segments stale all day, so the focus
    # sensor read `stale-Nm' and the P1–P4 predicates (which gate on
    # `sensor_status :focus = ok') could never confirm a positive
    # outcome.  The job is idempotent (atomic full rewrite of each
    # day's segments from raw) and cheap (~640 ms), and retention is a
    # no-op until its horizon, so running it every 10 min is safe and
    # keeps segments fresh for every tick's window.
    Unit.Description = "panopticon — derive segments + retention (intraday)";
    Timer = {
      Unit = "panopticon-segmentize.service";
      OnBootSec = "2min";
      OnUnitActiveSec = "10min";
      Persistent = true;
    };
    Install.WantedBy = ["timers.target"];
  };
}
