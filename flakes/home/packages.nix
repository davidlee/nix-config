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
    espanso-wayland
    flatpak
    gammastep
    inetutils
    nodejs_latest
    lutris
    nerd-font-patcher
    nixd
    nix-diff
    nix-index
    nix-search-cli
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
    wbg
    wireplumber
    wob
    wtype
  ];
}
