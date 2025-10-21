_: {
  flake.nixosModules.ai = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      cursor-cli
    ];
  };
}
