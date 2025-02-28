{ 
  pkgs,
  inputs,
  ...
}: {



  home.packages = with pkgs; [
    _1password-gui
    alacritty
    beeper
    beets
    blender
    cloudlens
    cmus
    code-cursor
    foot
    fooyin
    gamescope
    ghostty
    kando
    kitty
    mako
    manix
    mcfly
    obsidian
    oha
    quodlibet
    rofi-wayland
    signal-desktop
    slack
    somebar
    spotify
    superfile
    tauon
    tokei
    trippy
    virt-viewer 
    viu
    vivaldi
    ladybird
    librewolf
    firefox
    qutebrowser
    floorp
    ungoogled-chromium
    # midori
    # palemoon-bin
    vscode
    zed-editor
  ];
}
