_: let
  # https://github.com/johnalanwoods/maintained-modern-unix
  shellPackages = pkgs:
    with pkgs; [
      # session manager
      zellij

      ## alt shells
      # nushell
      # oils-for-unix
      # fish
      # xonsh

      ## charmbracelet
      freeze
      gum

      ## process management
      pstree
      killall

      ## docs, notes, productivity
      remind
      taskwarrior3

      ## converters
      pandoc
    ];
in {
  flake.nixosModules.shell = {pkgs, ...}: {
    environment.systemPackages = shellPackages pkgs;
  };

  flake.darwinModules.shell = {pkgs, ...}: {
    environment.systemPackages = shellPackages pkgs;
  };
}
