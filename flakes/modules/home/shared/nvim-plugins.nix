{
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
    # tree-sitter CLI + gcc: nvim-treesitter (`main`) compiles parsers at
    # runtime into stdpath('data')/site against nightly's own tree-sitter.
    deps = with pkgs; [selene tree-sitter gcc];
    eager = with pkgs.vimPlugins; [
      lze
      vim-startuptime
    ];
    lazy = with pkgs.vimPlugins; [
      # package management
      lzextras
      rocks-nvim
      rocks-config-nvim
      luasnip

      # # themes
      gruvbox
      gruvbox-material
      tokyonight-nvim
      papercolor-theme
      sonokai
      astrotheme

      # # completion
      blink-cmp # fzf rust ext
      luasnip
    ];
  };
}
