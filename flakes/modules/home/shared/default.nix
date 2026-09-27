{ ... }: {
  imports = [
    ./emacs.nix
    ./nvim.nix
    ./nvim-plugins.nix
    ./programs.nix
    ./shpool.nix
    ./zsh.nix
    ./nushell.nix
  ];
  home.sessionVariables = {
    EDITOR = "emacsclient";
    VISUAL = "emacsclient";
  };
}
