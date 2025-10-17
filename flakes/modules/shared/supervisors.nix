_: let
  supervisorsPackages = pkgs:
    with pkgs; [
      ## supervisors / runners
      # direnv
      just
      overmind
      watch
      watchman
      watcher
      watchexec
      fswatch
    ];
in {
  flake.nixosModules.supervisors = {pkgs, ...}: {
    environment.systemPackages = supervisorsPackages pkgs;
  };

  flake.darwinModules.supervisors = {pkgs, ...}: {
    environment.systemPackages = supervisorsPackages pkgs;
  };
}
