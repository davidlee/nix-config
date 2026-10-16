# Fun features, in projection order. Shape: README § Feature tree.
_: [
  {
    name = "toys";
    homeManager = {
      pkgs,
      lib,
      ...
    }: {
      home.packages = with pkgs;
        [
          figlet
        ]
        ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
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
