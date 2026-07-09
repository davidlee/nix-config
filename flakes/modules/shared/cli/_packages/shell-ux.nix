{pkgs, ...}: {
  ## shell prompt / completion / fuzzy-nav / session tools
  common = with pkgs; [
    starship
    carapace
    fzf
    atuin
    zoxide
    tmux
    abduco # shell persist
    dvtm # + abduco (suckless)
    shpool # vs abduco
    sesh
    skim
  ];
}
