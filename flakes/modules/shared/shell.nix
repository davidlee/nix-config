_: let
  # https://github.com/johnalanwoods/maintained-modern-unix
  shellPackages = pkgs:
    with pkgs; [
      ## zsh config depends on
      carapace
      eza
      lsd
      fzf
      atuin
      zoxide
      yazi
      broot
      tmux
      sesh
      skim
      delta

      # also lovely
      bat
      jless
      gdu
      ncdu
      hyperfine
      jq
      sd
      jc
      gron
      await
      xh
      doggo
      curlie
      httpie
      trashy
      ripgrep-all
      procs
      pls
      findutils
      dust
      duf
      choose
      glances
      gtop
      cheat
      tldr

      # session manager
      zellij

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

      ## charmbracelet
      freeze
      gum

      ## process management
      pstree
      killall

      ## docs, notes, productivity
      remind
      taskwarrior3

      ## PDF
      tdf

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
