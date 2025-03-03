{ 
  pkgs,
  inputs,
  ...
}: {

  home.packages = with pkgs; [
    _1password-gui
    alacritty
    beeper
    # beets
    blender
    cloudlens
    cmus
    code-cursor
    foot
    fooyin
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

    # browsers
    vivaldi
    ladybird
    librewolf
    firefox
    qutebrowser
    floorp
    ungoogled-chromium
    # midori
    palemoon-bin
    vscode
    zed-editor
    inputs.zen-browser.packages.${pkgs.system}.default
    thunderbird
    morgen
  ];
}
