{
  pkgs,
  lib,
  ...
}: {
  common = with pkgs; [
    git
    git-revise
    delta
    diffedit3
    diffnav
    diffr
    diffstat
    difftastic
    gh
    hub
    jujutsu
    mergiraf
    tig
    # debase # broken
    gh-dash
    lazygit
    lazyjj
    jjui
  ];
  linuxHome = with pkgs; [
    # hiPrio: superset of `git` in `common`; wins bin/git on Linux.
    (lib.hiPrio gitFull)
    gitui
  ];
}
