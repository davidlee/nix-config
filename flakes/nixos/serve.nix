{
  pkgs,
  username,
  ...
}: {
  services = {
    static-web-server = {
      enable = true;
      root = "/var/www";
      listen = "[::]:80";

      configuration = {
        general = {
          directory-listing = true;
        };
      };
    };

    postgresql = {
      enable = false;
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
}
