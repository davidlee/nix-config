_: let
  tuiPackages = pkgs:
    with pkgs; [
      ## text utils
      play # playground for sed, grep, awk, ...

      ## feeds, content / social
      russ # RSS
      tuir # reddit
      tut # mastodon
      tuisky # bluesky
      wiki-tui # wikipedia
      slack-term

      ## hex edit for infinite grenades
      hexpatch
      hextazy
      hexyl

      ## task / time / calendar mgmt
      # basilk
      # calcure
      # calcurse
      # gcalcli
      # taskflow
      # task-keeper
      # tasktimer
      # taskwarrior-tui
      # vault-tasks
      # vit

      ## habit trackers
      # dijo
      # harsh

      ## clock
      clock-rs
      # tty-clock

      # rust
      crates-tui

      ## www
      w3m-full
      browsh
      lynx
    ];
in {
  flake.nixosModules.tui = {pkgs, ...}: {
    environment.systemPackages = tuiPackages pkgs;
  };

  flake.darwinModules.tui = {pkgs, ...}: {
    environment.systemPackages = tuiPackages pkgs;
  };
}
