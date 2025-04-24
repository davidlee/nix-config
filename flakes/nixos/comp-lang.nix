{ pkgs, ... } : {
  
  environment.systemPackages = with pkgs; [
    # nix
    nix-bash-completions
    nixfmt-rfc-style
    
    # programming - general 
    exercism
    tree-sitter

    # vcs 
    gh
    # git 
    gitFull
    jj
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

    # supervisors / runners
    direnv
    overmind
    watchman
    just

    # www
    html-tidy
    prettierd

    # lang.c
    lldb
    valgrind
    lld
    llvm
    strace
    gcc
    
    # build
    bison
    gnumake
    ninja

    # lang.go
    gofumpt # go formatter
    
    # lang.python
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

    # lang.odin
    ols

    # lang.ruby
    ruby

    # lang.lua
    lua
    lua54Packages.luarocks-nix 
    vimPlugins.fzf-lua
    lua-language-server
    luarocks-packages-updater

    # lang.vim
    vim-language-server

    # lang.js
    bun
    pnpm
    corepack_latest
    nodejs_latest
    typescript-language-server
    typescript
    
    # lang.zig
    zig
    zls
    zig-shell-completions
  ];
}
