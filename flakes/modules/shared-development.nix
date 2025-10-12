{pkgs, ...}: {
  # keep this shit minimal -
  # use dev shells for project dependencies
  environment.systemPackages = with pkgs; [
    ## infrastructure
    sqlite

    ## programming - general
    exercism

    ## lang.go
    go

    ## lang.ruby
    ruby
    bundler
    # rake
    # rbenv

    ## lang.python
    uv

    ## lang.python
    uv

    ######## that's all

    # python3
    # python313Packages.pywatchman
    # python3Packages.pip

    # python3Packages.pyls-isort
    # python3Packages.pyls-flake8
    # python3Packages.flake8
    # python3Packages.isort
    # python3Packages.black
    # docutils
    # jupyter-all

    ## www
    # html-tidy
    # prettierd

    ## lang.elixir
    # elixir
    # lexical

    ## lang.odin
    # ols

    ## lang.clojure
    # clojure-lsp

    # lang.scheme
    # chez
    # chicken
    # guile

    ## lang.haskell
    # haskell-language-server
    # ghc

    ## lang.lua
    # lua
    # stylua
    # la51Packages.rocks-nvim
    # vimPlugins.fzf-lua
    # luarocks-packages-updater
    # lua-language-server

    ## lang.js
    # bun
    # pnpm
    # corepack_latest
    # nodejs_latest
    # typescript-language-server
    # typescript
    # emscripten
    # deno
    # nodejs_latest
    # eslint
    # prettier

    ## lang.zig
    # zig
    # zls
    # zig-shell-completions
  ];
}
