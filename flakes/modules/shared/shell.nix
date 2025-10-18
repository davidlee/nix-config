_: let
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
      remind
      taskwarrior3

      ## PDF
      tdf

      ## charmbracelet
      freeze
      gum

      ## converters
      pandoc

      ## frivolity
      neofetch
      fastfetch
      figlet
      fortune
      cmatrix
      nms
    ];
in {
  flake.nixosModules.shell = {pkgs, ...}: {
    environment.systemPackages = shellPackages pkgs;
  };

  flake.darwinModules.shell = {pkgs, ...}: {
    environment.systemPackages = shellPackages pkgs;
  };
}
