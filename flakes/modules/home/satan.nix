# SATAN — local agent runtime systemd wiring.
#
# NOT imported by hosts/Sleipnir.nix in phase 1.  Manual smoke test:
#   systemctl --user start satan-morning.service
#   systemctl --user status satan-morning.service
#   journalctl --user -u satan-morning.service
#
# Once trusted, import this module from the host's home-manager block.
# Wrapper at $HOME/.emacs.d/satan/bin/satan-run needs `emacsclient` and
# `jailed-satan-fake-harness` on PATH (the latter ships via
# `home.packages = [ inputs.emacsFlake.packages.x86_64-linux.satan-jailed-fake-harness ];`
# or by entering the .emacs.d devshell from the shell that launches the
# user session).
_: {
  flake.homeModules.satan = {...}: {
    systemd.user.services.satan-morning = {
      Unit = {
        Description = "SATAN morning run";
        Documentation = "file:%h/.emacs.d/SATAN.local.md";
      };
      Service = {
        Type = "oneshot";
        ExecStart = "%h/.emacs.d/satan/bin/satan-run morning";
      };
    };

    systemd.user.timers.satan-morning = {
      Unit.Description = "SATAN morning timer";
      Timer = {
        OnCalendar = "Mon..Sun 09:00";
        Persistent = true;
      };
      Install.WantedBy = ["timers.target"];
    };

    systemd.user.services.satan-motd = {
      Unit.Description = "SATAN motd refresh";
      Service = {
        Type = "oneshot";
        ExecStart = "%h/.emacs.d/satan/bin/satan-run motd";
      };
    };

    systemd.user.timers.satan-motd = {
      Unit.Description = "SATAN motd timer";
      Timer = {
        OnCalendar = "*-*-* 07:00";
        Persistent = true;
      };
      Install.WantedBy = ["timers.target"];
    };
  };
}
