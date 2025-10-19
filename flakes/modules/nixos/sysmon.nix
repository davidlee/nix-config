{pkgs, ...}: {
  flake.nixosModules.sysmon = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
    ];
  };
}
