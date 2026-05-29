# panopticon — local desktop-behaviour capture daemon.
#
# Source: ~/dev/panopticon (path: input — switch to git+file:// once stable).
# Writes JSONL to ~/.local/state/behaviour/{raw,current}.
#
# Smoke:
#   systemctl --user status panopticon-sway
#   journalctl --user -u panopticon-sway -f
#   tail -f ~/.local/state/behaviour/raw/sway-$(date +%F).jsonl
_: {
  flake.homeModules.behaviour = {
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
  };
}
