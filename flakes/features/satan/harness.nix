# SATAN — local agent runtime systemd wiring.
#
# Selected by personal-linux (the satan.harness feature; it requires editor.emacs
# because satan-run needs `emacsclient`); deployment notes: ~/flakes/SATAN.md.
# Manual smoke test:
#   systemctl --user start satan-morning.service
#   systemctl --user status satan-morning.service
#   journalctl --user -u satan-morning.service
#
# Since SL-012 the package lives in the standalone satan repo
# (~/dev/satan, flake input `satan`).  The wrapper at
# $HOME/dev/satan/satan/bin/satan-run needs `emacsclient` and the jailed
# harness `jailed-satan-gptel-harness` (flake attr
# `satan-jailed-gptel-harness`) on PATH; the latter is provisioned
# via `home.packages` below (lands in ~/.nix-profile/bin, on the broker's
# exec-path independent of any devshell/direnv).
{lib, ...}: {
  name = "harness";
  platforms = lib.platforms.linux;
  requires = ["editor.emacs"];
  homeManager = {
    inputs,
    pkgs,
    ...
  }: {
    home.packages = [
      inputs.satan.packages.${pkgs.stdenv.hostPlatform.system}.satan-jailed-gptel-harness
    ];

    systemd = {
      user = {
        timers = {
          satan-morning = {
            Unit.Description = "SATAN morning timer";
            Timer = {
              OnCalendar = "Mon..Sun 09:15";
              Persistent = true;
            };
            Install.WantedBy = ["timers.target"];
          };

          satan-motd = {
            Unit.Description = "SATAN motd timer";
            Timer = {
              OnCalendar = "*-*-* 08:15";
              Persistent = true;
            };
            Install.WantedBy = ["timers.target"];
          };
          satan-tick = {
            Unit.Description = "SATAN tick timer";
            Timer = {
              # Fires once, 5 minutes after boot.  The 30-minute recurrence and
              # jitter below are disabled (satan ISS-022).
              OnBootSec = "5min";
              # OnUnitActiveSec = "30min";
              # RandomizedDelaySec = "5min";
              Persistent = false;
            };
            Install.WantedBy = ["timers.target"];
          };
        };

        services = {
          satan-morning = {
            Unit = {
              Description = "SATAN morning run";
              Documentation = "file:%h/flakes/SATAN.md";
            };
            Service = {
              Type = "oneshot";
              ExecStart = "%h/dev/satan/satan/bin/satan-run morning";
            };
          };
          satan-motd.Unit.Description = "SATAN motd refresh";
          satan-motd.Service = {
            Type = "oneshot";
            ExecStart = "%h/dev/satan/satan/bin/satan-run motd";
          };
          satan-tick = {
            Unit.Description = "SATAN tick";
            Service = {
              Type = "oneshot";
              ExecStart = "%h/dev/satan/satan/bin/satan-run-tick";
            };
          };
        };
      };
    };
  };
}
