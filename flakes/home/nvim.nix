{
  pkgs,
  inputs,
  username,
  ...
}: let
  # ensure these are installed to the user environment as well as the nix
  # editor context for the least opportunity for nvim not to be able to find
  # them at runtime
  nvimDependencyPackages = with pkgs; [
    # general
    #
    ripgrep
    tectonic
    ast-grep
    imagemagick
    fzf
    gh
    gcc
    fd

    #
    # LSP / treesitter / formatters
    #

    # general
    #
    vscode-langservers-extracted
    emmet-language-server

    # general
    codespell

    # lua
    #
    lua-language-server
    stylua
    selene
    lua5_1
    lua51Packages.luarocks
    lua51Packages.rocks-git-nvim
    lua51Packages.rocks-dev-nvim

    # nix
    #
    nixd
    nixpkgs-fmt
    alejandra

    # ts
    #
    typescript-language-server
    prettierd

    # python
    #
    ruff
    python313Packages.jedi-language-server

    # ruby
    #
    ruby-lsp
    rubocop

    # shell
    #
    shfmt

    # erlang
    #
    beam27Packages.erlang-ls

    # go
    #
    gofumpt
    gopls
    golint
    golangci-lint
    gotools
    go-tools
    go
    delve

    # markdown
    #
    marksman
    markdown-oxide
    markdownlint-cli2
    vale
    valeStyles.alex
    valeStyles.google
    valeStyles.joblint
    valeStyles.microsoft
    valeStyles.proselint
    valeStyles.readability
    valeStyles.write-good

    # zig
    #
    zls
    zig-shell-completions

    # rust
    #
    rust-analyzer
    # rust-analyzer-nightly
  ];
in {
  # home-manager.users.${username}.
  home.packages = nvimDependencyPackages;

  programs.neovim = {
    enable = true;
    defaultEditor = true;

    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    withNodeJs = true;
    withPython3 = true;
    withRuby = true;

    # use bleeding edge nvim
    package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.neovim;

    #########################################
    # nix packages
    #########################################

    extraPackages = nvimDependencyPackages;

    # extraLuaPackages =

    #########################################
    # vimPlugins
    #########################################

    plugins = with pkgs.vimPlugins; [
      # package management
      lz-n
      lze
      lzextras
      rocks-nvim
      rocks-config-nvim
      rtp-nvim

      # libs
      plenary-nvim
      nui-nvim

      # meta
      mini-nvim
      mini-deps
      blink-compat
      nvim-nio

      # ui
      snacks-nvim
      mini-icons
      heirline-nvim
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

      # highlight
      vim-illuminate
      nvim-colorizer-lua
      rainbow-delimiters-nvim
      # nvim-highlight-colors

      # startup
      dashboard-nvim
      alpha-nvim
      vim-startuptime

      # themes
      gruvbox
      gruvbox-material
      tokyonight-nvim
      papercolor-theme
      sonokai
      astrotheme

      # amenities
      which-key-nvim
      vim-sleuth

      # projects / multiple files
      overseer-nvim
      grug-far-nvim
      # project-nvim

      # sessions
      persistence-nvim
      resession-nvim

      # files
      oil-nvim
      neo-tree-nvim
      triptych-nvim
      yazi-nvim

      # navigation
      outline-nvim
      leap-nvim
      fzf-lua
      aerial-nvim
      nvim-window-picker
      flash-nvim

      # editor
      vim-repeat
      nvim-autopairs
      yanky-nvim
      dial-nvim
      refactoring-nvim

      # completion
      blink-cmp
      blink-compat
      luasnip
      LuaSnip-snippets-nvim
      # nvim-cmp
      friendly-snippets
      cmp_luasnip
      cmp-buffer
      cmp-path
      cmp-nvim-lsp
      # nvim-snippets
      # cmp-mini-snippets

      # lint
      nvim-lint

      # format
      conform-nvim

      # test / debug
      trouble-nvim
      nvim-dap
      nvim-dap-ui
      nvim-dap-virtual-text
      neotest

      # lsp
      nvim-lspconfig
      luvit-meta
      # none-ls-nvim

      # treesitter
      nvim-treesitter.withAllGrammars
      nvim-treesitter-textobjects
      nvim-treesitter-textsubjects
      nvim-treesitter-context
      nvim-lsp-file-operations
      nvim-ts-autotag
      nvim-ts-context-commentstring

      # comments
      todo-comments-nvim

      #
      # Language specific / special modes
      #

      # lua
      lazydev-nvim
      one-small-step-for-vimkind
      neogen

      # git

      # js/ts
      vim-prettier

      # markdown
      vim-markdown-toc
      render-markdown-nvim
      markdown-preview-nvim

      # git / github
      octo-nvim

      # modes: other
      neorg
      orgmode
    ];
  };
}
