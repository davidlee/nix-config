{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    ## file find & search
    docfd
    television
    nix-search-tv
    nix-search-cli

    ## files / find
    fd
    file
    findutils
    # fsearch
    fzf-zsh
    fzy
    mcfly
    ripgrep
    vgrep
    sad
    trash-cli
    semgrep
    tree
    zoxide

    semgrep
  ];
}
