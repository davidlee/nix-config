{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    #
    # Nvim

    # treesitter
    nvim-treesitter.withAllGrammars
    nvim-treesitter-textobjects
    nvim-treesitter-textsubjects
    nvim-treesitter-context
    nvim-lsp-file-operations
    nvim-ts-autotag
    nvim-ts-context-commentstring

    #
    # LSP / treesitter / formatters
    #

    # general
    #
    vscode-langservers-extracted
    emmet-language-server
    treesitter
    tree-sitter-grammars

    # general
    codespell

    # lua
    #
    lua-language-server
    stylua
    selene
    lua5_1
    lua51Packages.luarocks
    # lua51Packages.rocks-git-nvim
    # lua51Packages.rocks-dev-nvim

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
    # python313Packages.jedi-language-server # BROKEN

    # ruby
    #
    ruby-lsp
    rubocop

    # shell
    #
    shfmt

    # erlang
    #
    # beam27Packages.erlang-ls

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
    #zls
    #zig-shell-completions

    # rust
    #
    rust-analyzer
    # rust-analyzer-nightly
  ];
}
