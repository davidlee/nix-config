# The home base (DEC-031): what every home gets. A host never imports it
# directly; it imports one platform layer, ./linux or ./darwin, which
# imports this.
{...}: {
  imports = [
    ./zsh.nix
    ./nushell.nix
    ./programs.nix
    ./shpool.nix
    ./cli.nix
    # editors and EDITOR/VISUAL, until they become editor.* features (SL-008 P4)
    ./shared
  ];

  programs.home-manager.enable = true;
}
