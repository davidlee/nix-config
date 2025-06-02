{username, ...}: {
  imports = [
    ../home/zsh.nix
    ../home/nvim.nix
    ../home/programs.nix
    # ../home/nixCats.nix

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
