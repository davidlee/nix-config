# The darwin home layer: the home base (../.) plus what only a Mac home
# needs. A darwin host's home.nix imports this directory; the Linux
# counterpart is ../linux. Host identity (username, homeDirectory,
# stateVersion) is in hosts/<host>/home.nix.
{config, ...}: {
  imports = [../.];

  # The user-bin PATH, prepended by hm-session-vars.sh; on Linux pam owns it
  # (modules/nixos/env.nix). List and order: ../../user-bin-path.nix (DEC-107).
  home.sessionPath = map (dir: "${config.home.homeDirectory}/${dir}") (import ../../user-bin-path.nix);

  # Move colliding files aside instead of failing activation; the policy
  # embedded Home Manager applied, kept for every home-switch.
  home.backupFileExtension = "backup";

  programs.kitty.darwinLaunchOptions = [
    "--listen-on=unix:/tmp/meow"
    "--single-instance"
  ];

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
