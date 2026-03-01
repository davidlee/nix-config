_: {
  flake.nixosModules.network = {
    hostname,
    options,
    ...
  }: {
    systemd.network.networks.enp8s0 = {
      defaultGateway = "192.168.0.1";
      addresses = [
        {
          Address = "192.168.0.9/24";
        }
      ];
      enable = true;
    };

    networking = {
      networkmanager = {
        enable = true;
        dns = "systemd-resolved";
        ensureProfiles.profiles.wired = {
          connection = {
            id = "wired";
            type = "ethernet";
            interface-name = "enp8s0";
          };
          ipv4 = {
            method = "auto";
            ignore-auto-dns = true;
          };
          ipv6 = {
            method = "auto";
            ignore-auto-dns = true;
          };
        };
      };

      hostName = hostname;
      timeServers = options.networking.timeServers.default ++ ["pool.ntp.org"];

      useDHCP = false;
      dhcpcd.enable = false;

      firewall = {
        enable = true;
        allowedTCPPorts = [22 80 443];
      };

      nftables.enable = true;
    };

    services = {
      stubby = {
        enable = true;
        settings = {
          resolution_type = "GETDNS_RESOLUTION_STUB";
          dns_transport_list = ["GETDNS_TRANSPORT_TLS"];
          tls_authentication = "GETDNS_AUTHENTICATION_REQUIRED";
          listen_addresses = ["127.0.0.1@8053" "0::1@8053"];
          idle_timeout = 10000;
          tls_connection_retries = 5;
          round_robin_upstreams = 1;

          upstream_recursive_servers = [
            {
              address_data = "76.76.2.22";
              tls_auth_name = "1qncxpyinu9.dns.controld.com";
            }
            {
              address_data = "2606:1a40::22";
              tls_auth_name = "1qncxpyinu9.dns.controld.com";
            }
          ];
        };
      };

      resolved = {
        enable = true;

        settings.Resolve = {
          Domains = ["~."];
          DNS = "127.0.0.1:8053";
          FallbackDNS = "76.76.2.22 2606:1a40::22";
          DNSSEC = false; # stubby is local proxy; ControlD validates upstream
          DNSOverTLS = false;
          MulticastDNS = false; # avahi handles mDNS
        };
      };
    };

    systemd.services.stubby.serviceConfig = {
      Restart = "on-failure";
      RestartSec = "2s";
    };
  };
}
