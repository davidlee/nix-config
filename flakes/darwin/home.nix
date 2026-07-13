{
  username,
  outputs,
  ...
}: {
  imports = [
    ../modules/home/shared/zsh.nix
    ../modules/home/shared/nvim-plugins.nix
    ../modules/home/shared/nvim.nix
    ../modules/home/shared/programs.nix
    ../modules/home/shared/emacs.nix
    outputs.homeModules.cliPackages # export until slice D
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
