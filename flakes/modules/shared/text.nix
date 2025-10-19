_: let
  textPackages = pkgs:
    with pkgs; [
      ## English
      #vale
      # vale-ls

      ## typing
      #thokr
      #ngrrram
    ];
in {
  flake.nixosModules.text = {pkgs, ...}: {
    environment.systemPackages = textPackages pkgs;
  };

  flake.darwinModules.text = {pkgs, ...}: {
    environment.systemPackages = textPackages pkgs;
  };
}
