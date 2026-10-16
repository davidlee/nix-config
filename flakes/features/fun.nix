# Fun features, in projection order. Shape: README § Feature tree.
{lib, ...}: let
  available = import ./available.nix lib;
in [
  {
    name = "toys";
    homeManager = {pkgs, ...}: {
      home.packages = with pkgs;
        [
          figlet
        ]
        ++ available pkgs [
          fastfetch
          fortune
          cmatrix
          nms

          # honeyfetch
          # nerdfetch
          # mufetch
          # meowfetch
        ];
    };
  }
]
