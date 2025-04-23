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

    taskchampion-sync-server = {
      enable = true; 
    };

    mpd = {
      enable = true;
      musicDirectory = "/media/music";
      extraConfig = ''
      '';
    };

  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
