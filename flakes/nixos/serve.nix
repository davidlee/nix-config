{ pkgs, username, ... }: {

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
      acceleration = "rocm";
      rocmOverrideGfx = "10.3.0";
      package = pkgs.ollama-rocm;
    };

    postgresql = {
      enable = false;
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
    };

    forgejo = {
      enable = false;
    };

    taskchampion-sync-server = {
      enable = false; 
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
