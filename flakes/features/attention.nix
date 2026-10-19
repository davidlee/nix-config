# Attention features, in projection order. Shape: README § Feature tree.
{lib, ...}: [
  (import ./attention/behaviour.nix {inherit lib;})

  # nudge — nudge toward Emacs (and the daily journal) from panopticon's
  # window history. A notification button runs the umbriel raise script.
  #
  # The scripts run live from this checkout, not the store: tuning rules and
  # thresholds (./attention/nudge/nudge.nu) needs no switch.
  #
  #   nu ~/flakes/features/attention/nudge/nudge-test.nu      tests
  #   nu ~/flakes/features/attention/nudge/main.nu --explain  current assessment
  #   journalctl --user -u nudge
  {
    name = "nudge";
    platforms = lib.platforms.linux;
    homeManager = {
      config,
      pkgs,
      ...
    }: {
      systemd.user.services.nudge = {
        Unit.Description = "nudge — toward Emacs and the journal";
        Service = {
          Type = "oneshot";
          ExecStart = "${pkgs.nushell}/bin/nu ${config.home.homeDirectory}/flakes/features/attention/nudge/main.nu";
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
    };
  }

  # goad — personal intervention shell.  A Slint window the host owns and a
  # user-supplied backend drives; one JSON document per exchange over stdio,
  # plus an ingress socket goad-emit writes to.  The host understands none of
  # the domain — items, slots and the record format are backend.py's business.
  #
  # Source: ~/dev/goad (git+file:// input — a git input, never `path:`: the
  # repo root holds a live unix socket nix refuses to copy, and only a git
  # input carries the self.shortRev that `goad --version` prints).
  #
  # State + artefacts:
  #   Config at ~/.config/goad/config.toml — the path `goad` with no argument
  #   reads.  It names the backend command and the ingress socket.
  #   Backend and its per-day records: ~/satan-corpus/goad/ (backend.py, data/).
  #   ~/.config/goad/env belongs to the *cargo* install path (`just install`)
  #   and is NOT read by this unit: the packaged binary is wrapped and carries
  #   LD_LIBRARY_PATH and FONTCONFIG_FILE itself, so there is no second file
  #   to drift against the build the unit runs.
  #
  # Replaces the hand-written unit at ~/satan-corpus/goad/goad.service.
  #
  # A refusal is exit 2 and the unit's RestartPreventExitStatus stops rather
  # than loops; the diagnostic naming the configuration file is on stderr.
  #
  # Smoke:
  #   systemctl --user status goad
  #   journalctl --user -u goad -f
  #   goad --version          # 0.1.0 (<rev>) — a bare 0.1.0 means a tarball
  {
    name = "goad";
    platforms = lib.platforms.linux;
    homeManager = {
      inputs,
      pkgs,
      ...
    }: {
      imports = [inputs.goad.homeManagerModules.default];

      services.goad = {
        enable = true;
        package = inputs.goad.packages.${pkgs.stdenv.hostPlatform.system}.goad;
        # The ingress socket is %t/satan/goad.sock, inside the directory
        # SATAN's jails bind; goad does not create a socket's parent.
        extraConfig.ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p %t/satan";
      };
    };
  }
]
