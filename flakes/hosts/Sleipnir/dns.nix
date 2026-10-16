# Site DNS: stubby forwards to ControlD over TLS, resolved points at stubby
# (DEC-029). The ControlD profile hostname is Private under POL-001; it stays
# here only until IMP-002 replaces this file.
_: {
  networking.networkmanager.dns = "systemd-resolved";

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
}
