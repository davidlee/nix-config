_: {
  flake.nixosModules.appimage = _: {
    programs = {
      appimage = {
        enable = true;
        binfmt = true;
      };
    };
  };
}
