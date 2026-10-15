{pkgs, ...}: {
  ## shell prompt / completion / fuzzy-nav / session tools
  common = with pkgs; [
    starship
    carapace
    fzf
    atuin
    zoxide
    tmux
    zmx # or this
    skim # $ sk

    # abduco # shell persist
    # dvtm # + abduco (suckless)
    # shpool # vs abduco . has a service too
    # sesh  # temporarily broken transitive dep: (go-mockery)
  ];
}
