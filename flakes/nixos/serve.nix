
{inputs, pkgs, ...}: {

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
          acme_ca https://acme-staging-v02.api.letsencrypt.org/directory
        }
    
        pktls.tplinkdns.com:443 {
          root /var/www
          file_server
          templates
          encode gzip
          acme_ca https://acme-staging-v02.api.letsencrypt.org/directory
        }

        pktls.tplinkdns.com:80 {
          redir https://pktls.tplinkdns.com/
        }
      '';
    };

    ollama = {
      enable = true;
    };

  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
