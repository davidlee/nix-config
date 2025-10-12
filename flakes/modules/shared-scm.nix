{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    ## SCM
    delta
    diffedit3
    diffnav
    diffr
    diffstat
    difftastic
    gh
    gitFull
    hub
    jujutsu
    mergiraf
    tig
    debase
    gh-dash
    lazygit
    lazyjj
    jjui
    # gitu
    # gitui # BROKEN
    # mercurial
    # meld
    # diffoscope
    # diffsitter
  ];
}
