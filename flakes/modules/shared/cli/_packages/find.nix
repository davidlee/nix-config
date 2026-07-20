{pkgs, ...}: {
  ## file find & search
  common = with pkgs; [
    docfd
    #    television
    nix-search-tv
    nix-search-cli
    fd
    file
    findutils
    fzy
    mcfly
    ripgrep
    vgrep
    sad
    ast-grep
    ripgrep-all
  ];
  linuxHome = with pkgs; [
    semgrep
    fsearch
  ];
}
