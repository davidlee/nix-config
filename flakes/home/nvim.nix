{
  pkgs,
  inputs,
  ...
}: let
  # ensure these are installed to the user environment as well as the nix
  # editor context for the least opportunity for nvim not to be able to find
  # them at runtime
  nvimDependencyPackages =
    # with pkgs;
    [
      # # general
      # #
      # ripgrep
      # # tectonic
      # ast-grep
      # imagemagick
      # fzf
      # gh
      # gcc
      # fd
      #
      # #
      # # LSP / treesitter / formatters
      # #
      #
      # # general
      # #
      # vscode-langservers-extracted
      # emmet-language-server
      #
      # # general
      # codespell
      #
      # # lua
      # #
      # lua-language-server
      # stylua
      # selene
      # lua5_1
      # lua51Packages.luarocks
      # # lua51Packages.rocks-git-nvim
      # # lua51Packages.rocks-dev-nvim
      #
      # # nix
      # #
      # nixd
      # nixpkgs-fmt
      # alejandra
      #
      # # ts
      # #
      # typescript-language-server
      # prettierd
      #
      # # python
      # #
      # ruff
      # # python313Packages.jedi-language-server # BROKEN
      #
      # # ruby
      # #
      # ruby-lsp
      # rubocop
      #
      # # shell
      # #
      # shfmt
      #
      # # erlang
      # #
      # # beam27Packages.erlang-ls
      #
      # # go
      # #
      # gofumpt
      # gopls
      # golint
      # golangci-lint
      # gotools
      # go-tools
      # go
      # delve
      #
      # # markdown
      # #
      # marksman
      # markdown-oxide
      # markdownlint-cli2
      # vale
      # valeStyles.alex
      # valeStyles.google
      # valeStyles.joblint
      # valeStyles.microsoft
      # valeStyles.proselint
      # valeStyles.readability
      # valeStyles.write-good
      #
      # # zig
      # #
      # #zls
      # #zig-shell-completions
      #
      # # rust
      # #
      # rust-analyzer
      # # rust-analyzer-nightly
    ];

  #
  # neovim.plugins
  #

  # Eager: these will be automatically loaded, but not required
  #
  nvimEagerPlugins = with pkgs.vimPlugins; [
    # package management
    lze

    # startup
    vim-startuptime
  ];

  # Lazy: plugins which should be available to the neovim runtime, but not autoloaded
  nvimLazyPlugins = with pkgs.vimPlugins; [
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
    leap-nvim
    fzf-lua
    aerial-nvim
    flash-nvim

    # editor
    dial-nvim
    refactoring-nvim
    nvim-autopairs
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
    nvim-treesitter-textobjects
    nvim-treesitter-textsubjects
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
    neorg
    orgmode
    vimoutliner
    zk-nvim

    # AI
    # aider-nvim
    codecompanion-nvim
  ];
in {
  home.packages = nvimDependencyPackages;

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

    extraPackages = nvimDependencyPackages;

    #########################################
    # vimPlugins
    #########################################

    plugins =
      nvimEagerPlugins
      ++ (map (p: {
          plugin = p;
          optional = true;
        })
        nvimLazyPlugins);
  };
}
