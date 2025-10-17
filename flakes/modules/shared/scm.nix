_: let
  scmPackages = pkgs:
    with pkgs; [
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
    ];
in {
  flake.nixosModules.scm = {pkgs, ...}: {
    environment.systemPackages = scmPackages pkgs;
  };

  flake.darwinModules.scm = {pkgs, ...}: {
    environment.systemPackages = scmPackages pkgs;
  };
}
# gitu
# gitui # BROKEN
# mercurial
# meld
# diffoscope
# diffsitter

