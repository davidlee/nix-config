_: {
  flake.nixosModules.cargo = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      cargo
    ];
  };
}
