{...}: {
  flake.homeModules.nvim = {
    pkgs,
    inputs,
    config,
    ...
  }: let
    inherit (config.nvimPackages) deps eager lazy;
  in {
    home.packages = deps;

    programs.neovim = {
      enable = true;
      defaultEditor = true;

      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;

      # withNodeJs = true;
      # withPython3 = true;
      # withRuby = true;

      # use bleeding edge nvim
      package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.neovim;

      #########################################
      # nix packages
      #########################################

      extraPackages = deps;

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
