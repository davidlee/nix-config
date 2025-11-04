_: {
  flake.nixosModules.gui = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      # zeal # like dash
    ];
  };
}
