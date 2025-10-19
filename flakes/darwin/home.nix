{
  username,
  outputs,
  ...
}: {
  imports = [
    outputs.homeModules.zsh
    outputs.homeModules.nvim-plugins
    outputs.homeModules.nvim
    outputs.homeModules.programs
  ];

  home = {
    homeDirectory = "/Users/${username}";
    stateVersion = "24.11";
  };

  programs = {
    home-manager.enable = true;
    kitty.darwinLaunchOptions = [
      "--listen-on=unix:/tmp/meow"
      "--single-instance"
    ];
  };

  targets.darwin.defaults = {
    # NSGlobalDomain = {
    # };

    # "com.apple.dock" = {
    # };

    # "com.apple.finder" = {
    # };

    # "com.apple.Safari" = {
    # };

    "com.apple.desktopservices".DSDontWriteUSBStores = true;
  };
}
