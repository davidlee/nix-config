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
  
  
  # gui stuff should go in wayland.nix
  home.packages = with pkgs; [
    _1password-cli
    ccache
    devcontainer
    dfu-util
    difftastic
    dmidecode
    docker
    dtc
    flatpak
    inetutils
    nodejs_latest
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
    swww
    unixtools.nettools
    unixtools.xxd
    wbg
    wireplumber
    wob
    wtype
  ];
}
