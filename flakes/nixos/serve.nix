{ pkgs, ... }: {

  services = {

    caddy = {
      enable = true;
      dataDir = "/var/www";
      configFile = pkgs.writeText "Caddyfile" ''
        localhost {
          root /var/www
          file_server browse
          templates
          encode gzip
          # acme_ca https://acme-staging-v02.api.letsencrypt.org/directory
        }
    
        pktls.tplinkdns.com:443 {
          root /var/www
          file_server
          templates
          encode gzip
          # acme_ca https://acme-staging-v02.api.letsencrypt.org/directory
        }

        pktls.tplinkdns.com:80 {
          redir https://pktls.tplinkdns.com/
        }
      '';
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
          # superuser = true;
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
