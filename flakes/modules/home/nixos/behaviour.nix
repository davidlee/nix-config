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
  };
}
