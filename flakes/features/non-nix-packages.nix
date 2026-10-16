# Package management outside Nix: third-party app formats, in projection
# order. Shape: README § Feature tree.
_: [
  {
    name = "appimage";
    nixos = _: {
      programs.appimage = {
        enable = true;
        binfmt = true;
      };
    };
  }

  {
    name = "flatpak";
    nixos = _: {
      services.flatpak.enable = true;
    };
  }
]
