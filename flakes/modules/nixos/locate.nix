_: {
  flake.nixosModules.locate = {
    pkgs,
    username,
    ...
  }: {
    services = {
      locate = {
        enable = true;
        package = pkgs.plocate;
        interval = "hourly";

        prunePaths = [
          "/tmp"
          "/var/tmp"
          "/var/cache"
          "/var/lock"
          "/var/run"
          "/var/spool"
          "/nix/store"
          "/nix/var/log/nix"
        ];
      };
    };
  };
}
