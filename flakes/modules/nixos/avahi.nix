_: {
  flake.nixosModules.avahi = {pkgs, ...}: {
    services = {
      avahi = {
        enable = true;
        nssmdns4 = true;
        openFirewall = true;
      };
    };
  };
}
