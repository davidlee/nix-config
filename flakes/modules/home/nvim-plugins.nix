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
        rtp-nvim
        lz-n

        # libs
        plenary-nvim
        blink-compat
        nui-nvim

        # meta / frameworks
        mini-nvim
        mini-deps
        nvim-nio

        # themes
        gruvbox
        gruvbox-material
        tokyonight-nvim

        papercolor-theme
        sonokai
        # astrotheme

        # ui
        snacks-nvim
        mini-icons
        lualine-nvim
        lualine-lsp-progress
        gitsigns-nvim
        snacks-nvim
        bufferline-nvim
        smart-splits-nvim
        nvim-notify
        noice-nvim
        edgy-nvim
        smear-cursor-nvim
        nvim-navic
        heirline-nvim

        # highlight
        nvim-colorizer-lua
        rainbow-delimiters-nvim

        # startup
        dashboard-nvim
        alpha-nvim

        # amenities
        which-key-nvim
        vim-sleuth

        # projects / multiple files
        overseer-nvim
        grug-far-nvim

        # sessions
        persistence-nvim
        resession-nvim

        # navigation
        nvim-window-picker
        # outline-nvim
        # leap-nvim
        #fzf-wrapper
        #fzf-lua
        aerial-nvim
        flash-nvim

        # editor
        dial-nvim
        refactoring-nvim
        nvim-autopairs
        auto-save-nvim
        yanky-nvim

        # test / debug
        trouble-nvim

        # lint
        nvim-lint

        # format
        conform-nvim

        # completion
        blink-cmp
        blink-compat
        luasnip
        LuaSnip-snippets-nvim
        friendly-snippets
        cmp_luasnip
        cmp-buffer
        cmp-path
        cmp-nvim-lsp

        # comments
        todo-comments-nvim

        # files
        oil-nvim
        neo-tree-nvim
        triptych-nvim
        yazi-nvim

        # test / debug
        nvim-dap
        nvim-dap-ui
        nvim-dap-virtual-text
        neotest

        # lsp
        luvit-meta
        nvim-lspconfig

        # treesitter
        nvim-treesitter.withAllGrammars
        # nvim-treesitter-textobjects  # conflicts with withAllGrammars
        # nvim-treesitter-textsubjects  # conflicts with withAllGrammars
        nvim-treesitter-context
        nvim-lsp-file-operations
        nvim-ts-autotag
        nvim-ts-context-commentstring

        # lang.js (ts)
        vim-prettier

        # lang.lua
        one-small-step-for-vimkind
        # lazydev-nvim

        # lang.markdown
        markdown-preview-nvim
        vim-markdown-toc
        render-markdown-nvim

        # mode.git / github
        octo-nvim

        # modes: other
        # neorg # bundles nvim-treesitter, conflicts with withAllGrammars
        orgmode
        vimoutliner
        zk-nvim

        # AI
        # aider-nvim
        codecompanion-nvim
      ];
    };
  };
}
