{ 
  pkgs,
  inputs,
  ...
}: {

  imports = [
    ./packages_shared.nix
  ];

  # home.packages = with inputs.nixpkgs-stable; [
  #   harlequin
  # ];
  
  
  home.packages = with pkgs; [
    _1password-cli
    ccache
    devcontainer
    dfu-util
    difftastic
    discord
    dmidecode
    docker
    dtc
    flatpak
    gammastep
    go
    inetutils
    lua
    lua54Packages.luarocks-nix 
    lua-language-server
    luarocks-packages-updater
    lutris
    nerd-font-patcher
    nixd
    nix-diff
    nix-index
    nix-search-cli
    nodejs_latest
    nwg-look
    p7zip
    qemu
    qmk-udev-rules
    sd-switch
    steamcmd
    steam-tui
    swayr
    swww
    unixtools.nettools
    unixtools.xxd
    vimPlugins.fzf-lua
    virtualenv
    wbg
    wireplumber
    wob
    wtype
    # zig
  ];
}
