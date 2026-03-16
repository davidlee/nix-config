_: {
  flake.nixosModules.postgresql = {
    username,
    pkgs,
    ...
  }: {
    services = {
      postgresql = {
        package = pkgs.postgresql_18;
        enable = true;
        ensureUsers = [
          {
            name = username;
            ensureDBOwnership = true;
            ensureClauses = {
              superuser = true;
              createrole = true;
              createdb = true;
            };
          }
        ];
        ensureDatabases = [
          username
          "corpus"
          "tasks"
        ];
        enableTCPIP = false;
      };
    };
    networking.firewall.allowedTCPPorts = [80 443];
  };
}
