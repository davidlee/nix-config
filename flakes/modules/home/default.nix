# The home base (DEC-031): what every home gets. A host never imports it
# directly; it imports one platform layer, ./linux or ./darwin, which
# imports this.
{...}: {
  imports = [
    ./nushell.nix
    ./programs.nix
    ./cli.nix
  ];

  programs.home-manager.enable = true;
}
