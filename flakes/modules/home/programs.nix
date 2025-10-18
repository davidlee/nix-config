_: {
  flake.homeModules.programs = {pkgs, ...}: {
    #
    # shared home-manager programs
    #

    programs = {
      nix-search-tv.enableTelevisionIntegration = true;

      direnv = {
        enable = true;
        silent = true;
        enableZshIntegration = true;
        enableBashIntegration = true;
        nix-direnv.enable = true;
      };

      starship = {
        enable = true;
        enableZshIntegration = true;
        enableNushellIntegration = true;
        settings =
          pkgs.lib.importTOML ../../files/starship.toml
          // {
            scan_timeout = 100;
            command_timeout = 750;
          };
      };
    };
  };
}
