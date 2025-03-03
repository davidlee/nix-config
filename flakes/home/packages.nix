{ 
  pkgs,
  inputs,
  ...
}: {

  imports = [
    ./packages_shared.nix
  ];

  # gui stuff should go in wayland.nix
  home.packages = with pkgs; [
    _1password-cli
    ccache
    devcontainer
    dfu-util
    difftastic
    dmidecode
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
    qmk-udev-rules
    sd-switch
    swww
    unixtools.nettools
    unixtools.xxd
    wbg
    wireplumber
    wob
    wtype
  ];
}
