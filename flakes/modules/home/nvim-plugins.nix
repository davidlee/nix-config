_: {
  flake.homeModules.nvim-plugins = {
    pkgs,
    lib,
    ...
  }: {
    options.nvimPackages = {
      deps = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [];
      };
      eager = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [];
      };
      lazy = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [];
      };
    };

    config.nvimPackages = {
      deps = with pkgs; [selene];
      eager = with pkgs.vimPlugins; [
        lze
        vim-startuptime
      ];
      lazy = with pkgs.vimPlugins; [
        # package management
        lzextras
        rocks-nvim
        rocks-config-nvim

        # # themes
        gruvbox
        gruvbox-material
        tokyonight-nvim
        papercolor-theme
        sonokai
        astrotheme

        # # completion
        blink-cmp # fzf rust ext
      ];
    };
  };
}
