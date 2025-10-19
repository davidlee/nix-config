_: let
  tuiPackages = pkgs:
    with pkgs; [
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
    ];
in {
  flake.nixosModules.tui = {pkgs, ...}: {
    environment.systemPackages = tuiPackages pkgs;
  };

  flake.darwinModules.tui = {pkgs, ...}: {
    environment.systemPackages = tuiPackages pkgs;
  };
}
