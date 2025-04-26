{ pkgs, ... } : {
  
  environment.systemPackages = with pkgs; [
    ## programming - general 
    exercism
    tree-sitter

    ## SCM
    gh
    gitFull
    jujutsu
    hub
    delta
    difftastic
    diffnav
    jujutsu
    sublime-merge
    meld
    diffr
    diffsitter
    diffstat
    diffedit3
    diffoscope
    mergiraf
    tig

    ## supervisors / runners
    direnv
    just
    overmind
    watch
    watchman
    watcher
    watchexec
    
    ## build system
    gnumake
    ninja

    ## www
    html-tidy
    prettierd

    ## utility LSPs
    lsp-ai
    simple-completion-language-server
    dot-language-server
    yaml-language-server
    tooling-language-server
    mdx-language-server
    docker-language-server
    bash-language-server
    vim-language-server
    # just-lsp
    postgres-lsp
    typos-lsp
    htmx-lsp
    jq-lsp
    fish-lsp
    ctags-lsp

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
    qmk-udev-rules
    dfu-util
    qmk
    dtc

    ## ai 
    ollama
    oterm
    aichat
    local-ai
    mods

    ## parse / lex
    bison
    
    ## lang.c
    lldb
    valgrind
    lld
    llvm
    strace
    gcc
    
    ## lang.elixir 
    lexical

    ## lang.go
    gofumpt # go formatter
    
    ## lang.python
    uv
    python313Packages.pywatchman
    python3Packages.python-lsp-server
    python3Packages.python-lsp-ruff
    python3Packages.python-lsp-jsonrpc
    python3Packages.python-lsp-black
    python3Packages.pyls-isort
    python3Packages.pyls-flake8
    python3Packages.flake8
    python3Packages.isort
    python3Packages.black
    jupyter-all

    ## lang.odin
    ols

    ## lang.clojure
    clojure-lsp

    ## lang.haskell
    haskell-language-server

    ## lang.ruby
    ruby
    ruby-lsp
    bundler
    rake

    ## lang.lua
    lua
    lua54Packages.luarocks-nix 
    vimPlugins.fzf-lua
    lua-language-server
    luarocks-packages-updater

    ## lang.js
    bun
    pnpm
    corepack_latest
    nodejs_latest
    typescript-language-server
    typescript
    emscripten
    
    ## lang.zig
    zig
    zls
    zig-shell-completions
  ];
}
