# Apps features, in projection order. Shape: README § Feature tree. Where an
# application belongs is still open (IMP-016); this area holds what has moved.
_: [
  {
    name = "cad";
    homeManager = {pkgs, ...}: {
      home.packages = with pkgs; [
        openscad # openscad-unstable
      ];
    };
  }
]
