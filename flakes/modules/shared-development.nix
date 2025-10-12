{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    ## programming - general
    exercism

    ## alt shells
    # nushell
    # oils-for-unix
    # fish
    # xonsh

    ## charmbracelet
    # vhs
    freeze
    gum
    # skate

    ## SCM
    delta
    diffedit3
    diffnav
    # diffoscope
    diffr
    # diffsitter
    diffstat
    difftastic
    gh
    gitFull
    # mercurial
    hub
    jujutsu
    # meld
    mergiraf
    tig

    ## supervisors / runners
    # direnv
    just
    overmind
    watch
    watchman
    watcher
    watchexec
    fswatch

    ## build systems
    gnumake
    ninja
    autoconf
    cmake
    # redo-apenwarr

    ## www
    # html-tidy
    prettierd

    ## editor platforms: LSP / treesitter
    tree-sitter
    lsp-ai
    simple-completion-language-server
    # dot-language-server
    # yaml-language-server
    # tooling-language-server

    # docker-language-server
    # bash-language-server
    # vim-language-server
    # just-lsp
    # postgres-lsp
    # typos-lsp
    # htmx-lsp
    # jq-lsp
    # fish-lsp
    # ctags-lsp

    ## cli dev utils
    semgrep

    ## json/yaml
    jq
    yq-go

    ## markdown
    markdownlint-cli
    markdownlint-cli2
    markdown-oxide
    marksman

    ## keyboard firmware
    dfu-util
    qmk
    dtc

    ## parse / lex
    bison

    ## lang.c
    lldb
    lld
    llvm
    gcc
    clangStdenv
    libclang

    ## lang.elixir
    # elixir
    # lexical

    ## lang.go
    go
    gofumpt # go formatter

    ## lang.python
    python3
    uv
    # python313Packages.pywatchman
    # python3Packages.pip
    # python3Packages.python-lsp-server
    # python3Packages.python-lsp-ruff
    # python3Packages.python-lsp-jsonrpc
    # python3Packages.python-lsp-black
    # python3Packages.pyls-isort
    # python3Packages.pyls-flake8
    # python3Packages.flake8
    # python3Packages.isort
    # python3Packages.black
    # docutils
    # jupyter-all

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

    ## lang.ruby
    ruby
    # ruby-lsp
    bundler
    # rake
    # rbenv

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
