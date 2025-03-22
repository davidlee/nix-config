{ pkgs, ... }: {

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

    ollama = {
      enable = true;
    };

    postgresql = {
      enable = true;
      ensureUsers = [{
        name = "david";
        ensureDBOwnership = true;
        ensureClauses = {
          superuser = true;
          createrole = true;
          createdb = true;
        };
      }];
      ensureDatabases = [ "david" ];
      enableTCPIP = false;
      # extensions = [ ];
    };

    # FIXME upstream service needs patch
    # taskchampion-sync-server = {
    #   enable = true; 
    #   openFirewall = true;
    #   allowClientIds = [ ];
    # };

  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
