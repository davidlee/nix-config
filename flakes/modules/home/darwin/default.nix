# The darwin home layer: the home base (../.) plus what only a Mac home
# needs. A darwin host's home.nix imports this directory; the Linux
# counterpart is ../linux. Host identity (username, homeDirectory,
# stateVersion) is in hosts/<host>/home.nix.
{lib, ...}: {
  imports = [../.];

  # atuin 18.23.0 (nixpkgs 7fd4004) is not cached for aarch64-darwin and
  # fails to build locally; restore when it is (ISS-007; probe:
  # workarounds/default.nix).
  programs.atuin.enable = lib.mkForce false;

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
