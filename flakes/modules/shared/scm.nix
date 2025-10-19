_: let
  scmPackages = pkgs:
    with pkgs; [
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

