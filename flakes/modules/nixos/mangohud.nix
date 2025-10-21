_: {
  flake.nixosModules.mangohud = {
    pkgs,
    username,
    ...
  }: {
    ## home manager for the things only it supports
    home-manager.users.${username} = {
      programs = {
        mangohud.enable = true;
      };
    };

    environment = {
      sessionVariables = {
        # use it for everything
        # MANGOHUD = 1;
      };

      systemPackages = with pkgs; [
        mangohud
      ];
    };
  };
}
