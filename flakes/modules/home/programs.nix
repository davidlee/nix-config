_: {
  flake.homeModules.programs = {pkgs, ...}: {
    programs = {
      nix-search-tv.enableTelevisionIntegration = true;

      direnv = {
        enable = true;
        silent = true;
        enableZshIntegration = true;
        enableBashIntegration = true;
        nix-direnv.enable = true;
      };
    };
  };
}
