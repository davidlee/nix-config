{ 
  pkgs,
  inputs,
  username,
  ...
}: {
  # https://github.com/project-gauntlet/gauntlet

  environment.systemPackages = [ inputs.gauntlet.packages.${pkgs.system}.default ];

  # nixpkgs.overlays = [ inputs.gauntlet.overlays.default ];
  # 
  home-manager.users.${username} = {
    # imports = [ inputs.gauntlet.homeManagerModules.default ];
    # programs.gauntlet = {
    #   enable = true;
    #   service.enable = true;
    #   config = {};
    # };
  };
}
