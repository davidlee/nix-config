_: {
  flake.nixosModules.postgresql = {username, ...}: {
    services = {
      postgresql = {
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
        ensureDatabases = [username];
        enableTCPIP = false;
      };
    };
    networking.firewall.allowedTCPPorts = [80 443];
  };
}
