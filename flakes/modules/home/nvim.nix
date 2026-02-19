_: {
  flake.homeModules.nvim = {
    pkgs,
    inputs,
    config,
    lib,
    ...
  }: let
    inherit (config.nvimPackages) deps eager lazy;
  in {
    home.packages = deps;

    programs.neovim = {
      enable = true;
      defaultEditor = true;

      initLua = ''
        require("boot");
      '';

      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;

      # withNodeJs = true;
      # withPython3 = true;
      # withRuby = true;

      # use bleeding edge nvim
      package = inputs.neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}.neovim;

      #########################################
      # nix packages
      #########################################

      extraPackages = deps;

      # put nvim libs before system ones
      #
      # extraWrapperArgs = [
      #   "--prefix"
      #   "PATH"
      #   ":"
      #   "${lib.makeBinPath [pkgs.gcc]}"
      # ];

      #########################################
      # vimPlugins
      #########################################

      plugins =
        eager
        ++ (map (p: {
            plugin = p;
            optional = true;
          })
          lazy);
    };
  };
}
