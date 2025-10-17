{...}: let
  shellPackages = pkgs:
    with pkgs; [
      ## cli history
      atuin

      # session manager
      zellij
      tmux
      # screen

      ## alt shells
      # nushell
      # oils-for-unix
      # fish
      # xonsh

      ## zsh / posix
      zsh
      zstd
      zsh-autocomplete
      antidote
      shellcheck
      shfmt

      # tmux session / plugins
      sesh

      ## process management
      pstree
      killall

      ## docs, notes, productivity
      tealdeer
      pinfo
      zeal
      dnote
      remind
      taskwarrior3

      ## charmbracelet
      # vhs
      freeze
      gum
      # skate

      ## frivolity
      neofetch
      fastfetch
      figlet
    ];
in {
  flake.nixosModules.shell = {pkgs, ...}: {
    environment.systemPackages = shellPackages pkgs;
  };

  flake.darwinModules.shell = {pkgs, ...}: {
    environment.systemPackages = shellPackages pkgs;
  };
}
