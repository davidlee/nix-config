_: {
  flake.nixosModules.devel-base = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
    ];
  };
}
