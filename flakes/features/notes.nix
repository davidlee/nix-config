# Notes features, in projection order. Shape: README § Feature tree.
{lib, ...}: let
  available = import ./available.nix lib;
in [
  {
    name = "terminal";
    homeManager = {pkgs, ...}: {
      home.packages = available pkgs (with pkgs; [
        kb
        nb
        tpnote
        tui-journal
      ]);
    };
  }

  # Hourly commits of prose repos edited by hand, so a capsule room that sees
  # a repo as its last commit sees today's work (CHR-022). Skips, rather than
  # fails, when a person is mid-commit; ./notes/autocommit says when, and
  # `autocommit-test` beside it holds that behaviour. Push stays manual.
  #
  # Smoke:
  #   systemctl --user list-timers 'autocommit-*'
  #   journalctl --user -u autocommit-notes
  {
    name = "autocommit";
    platforms = lib.platforms.linux;
    homeManager = {pkgs, ...}: let
      # Under $HOME. A repo not checked out here is skipped, not failed.
      repos = ["notes" "satan-corpus"];
      unit = repo: "autocommit-${repo}";
      eachRepo = f: lib.listToAttrs (map (repo: lib.nameValuePair (unit repo) (f repo)) repos);
    in {
      # A plain script in ~/.local/bin, as snooze-nag is: runnable by hand.
      home.file.".local/bin/autocommit" = {
        source = ./notes/autocommit;
        executable = true;
      };

      systemd.user = {
        services = eachRepo (repo: {
          Unit = {
            Description = "Commit ~/${repo}";
            ConditionPathExists = "%h/${repo}/.git";
          };
          Service = {
            Type = "oneshot";
            ExecStart = "%h/.local/bin/autocommit %h/${repo}";
            # git reads the user's identity from $HOME, which the manager sets.
            Environment = "PATH=${lib.makeBinPath (with pkgs; [bash git coreutils])}";
          };
        });

        timers = eachRepo (repo: {
          Unit.Description = "Commit ~/${repo} hourly";
          Install.WantedBy = ["timers.target"];
          Timer = {
            Unit = "${unit repo}.service";
            OnCalendar = "hourly";
          };
        });
      };
    };
  }

  {
    name = "joplin";
    platforms = lib.platforms.linux;
    homeManager = {pkgs, ...}: {
      home.packages = with pkgs; [
        joplin
        # obsidian
      ];
    };
  }
]
