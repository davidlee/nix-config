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

      # meta
      mini-nvim
      mini-deps
      plenary-nvim
      blink-compat
      nvim-nio

      # ui
      snacks-nvim
      nvim-web-devicons
      mini-icons
      heirline-nvim
      lualine-nvim
      lualine-lsp-progress
      gitsigns-nvim
      snacks-nvim
      bufferline-nvim
      vim-illuminate
      nvim-notify
      noice-nvim
      nui-nvim
      edgy-nvim
      alpha-nvim
      dashboard-nvim
      dressing-nvim
      smear-cursor-nvim

      # themes
      gruvbox
      gruvbox-material
      tokyonight-nvim
      papercolor-theme
      sonokai
      astrotheme

      # amenities
      which-key-nvim
      vim-startuptime
      vim-sleuth
      todo-comments-nvim
      smart-splits-nvim
      toggleterm-nvim
      resession-nvim
      grug-far-nvim
      persistence-nvim
      outline-nvim
      overseer-nvim
      octo-nvim
      project-nvim

      # files
      oil-nvim
      neo-tree-nvim
      triptych-nvim
      yazi-nvim

      # navigation
      leap-nvim
      fzf-lua
      aerial-nvim
      nvim-window-picker
      telescope-nvim
      flit-nvim
      nvim-navic
      flash-nvim
      telescope-fzf-native-nvim

      # editor
      vim-repeat
      nvim-autopairs
      better-escape-nvim
      neogen
      yanky-nvim
      dial-nvim
      inc-rename-nvim
      refactoring-nvim
      indent-blankline-nvim

      # completion
      blink-cmp
      luasnip
      nvim-highlight-colors
      nvim-cmp
      friendly-snippets
      cmp_luasnip
      cmp-buffer
      cmp-path
      cmp-nvim-lsp
      nvim-snippets
      # cmp-mini-snippets

      # lint
      nvim-lint

      # format
      conform-nvim

      # test / debug
      nvim-dap
      nvim-dap-ui
      nvim-dap-virtual-text
      trouble-nvim
      neotest

      # lsp
      nvim-lspconfig
      luvit-meta
      none-ls-nvim

      # treesitter
      nvim-treesitter.withAllGrammars
      nvim-treesitter-textobjects
      nvim-treesitter-context
      # nvim-lsp-file-operations
      nvim-ts-autotag
      nvim-ts-context-commentstring

      #
      # Language specific
      #

      # lua
      lazydev-nvim
      one-small-step-for-vimkind

      # git

      # js/ts
      vim-prettier

      # markdown
      vim-markdown-toc
      render-markdown-nvim
      markdown-preview-nvim
    ];
  };
}
