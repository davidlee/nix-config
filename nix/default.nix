{
  nix = {
    channel.enable = false;
    nixPath = ["nixpkgs=/etc/nixos/nixpkgs"];
    settings = {
      experimental-features = "nixt-command";
    };
  };

  environment.etc = {
    "nixos/nixpkgs".source = builtins.storePath pkgs.path;
  };

  sources = ./npins;
  configuration = import ./hosts/Sleipnir/configuration.nix;
}
