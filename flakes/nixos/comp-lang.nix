{ pkgs, ... } : {
  
  environment.systemPackages = with pkgs; [
    
    # nix
    nix-bash-completions
    nixfmt-rfc-style
    
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
    pipx
    python313Packages.pywatchman
    python313Packages.pip
    docutils
    meson

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

    #
    # libs
    # 
    # - graphic  
    libxkbcommon
    directx-headers
    vulkan-headers
    vulkan-loader
    vulkan-tools
    raylib
    libGL
    wayland-scanner
    wayland-protocols
    wayland-utils
    xorg.libX11
    xorg.libX11.dev
    xorg.libXcursor
    xorg.libXi
    xorg.libXinerama
    xorg.libXrandr
    # - misc 
    polkit
    libyaml
    libffi
    glib
    libiconv
    libnotify
    emscripten

  ];
}
