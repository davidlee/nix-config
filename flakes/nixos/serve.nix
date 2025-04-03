{ username, ... }: {

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
        name = username;
        ensureDBOwnership = true;
        ensureClauses = {
          superuser = true;
          createrole = true;
          createdb = true;
        };
      }];
      ensureDatabases = [ username ];
      enableTCPIP = false;
      # extensions = [ ];
    };

    forgejo = {
      enable = true;
    };

    # # FIXME upstream service needs patch
    # # https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/services/misc/taskchampion-sync-server.nix
    # taskchampion-sync-server = {
    #   enable = true; 
    #   # openFirewall = true;
    #   allowClientIds = [ ];
    # };

  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
