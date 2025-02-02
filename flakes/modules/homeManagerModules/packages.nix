{
  pkgs,
  host,
  username,
  ...
}: {
  home.packages = with pkgs; [
    # inputs.hyprland-qtutils.packages."${pkgs.system}".default
    # pkgs.fzf
    # pkgs.glow # markdown previewer in terminal
    iotop # io monitoring
    iftop # network monitoring
    usbutils # lsusb
    hyprland
    # hyprlandPlugins.hyprscroller
  ];
}
