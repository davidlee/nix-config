{
  hostname,
  options,
  lib,
  pkgs,
  ...
}: {
  services.tailscale.enable = true;

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
        # Static IP owned declaratively by this profile (not a router DHCP
        # reservation). keyfile format: address1 = "IP/prefix,gateway".
        ipv4 = {
          method = "manual";
          address1 = "192.168.0.9/24,192.168.0.1";
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
      # ~/dev/microvm-spike/ — the capsule's point-to-point tap, scoped to the
      # two services the guest is meant to reach (egress proxy, git daemon).
      # NOT trustedInterfaces: that accepts everything on the iface, which put
      # every 0.0.0.0-bound host service (sshd, caddy on 80/8080, …) inside the
      # jail's reach. Interface-scoped rather than allowedTCPPorts, which would
      # also open these on enp8s0 and tailscale0.
      interfaces."vm-capsule".allowedTCPPorts = [3128 9418];
    };

    nftables.enable = true;

    # The tap is an endpoint, never a transit path. The guest has no default
    # route, but a guest that gains root can add one, and then the only thing
    # between it and the LAN is whether this host forwards —
    # `net.ipv4.ip_forward` is global and both docker and tailscale turn it on
    # for their own reasons, so it cannot be left to inspection.
    #
    # Its own table, not `networking.firewall.filterForward`: that switches the
    # whole host's forward policy to drop and would take those same daemons
    # out. A `drop` verdict is terminal in any chain, so a separate table needs
    # no cooperation from the firewall's.
    #
    # `capsule-host` and `capsule-net` verify this table is present and refuse
    # to run without it once forwarding is live (see the sudo read rule in
    # security.nix). Renaming the table or the rules breaks that check.
    nftables.tables.capsule-forward = {
      family = "inet";
      content = ''
        chain forward {
          type filter hook forward priority filter - 10; policy accept;
          iifname "vm-capsule" drop
          oifname "vm-capsule" drop
        }
      '';
    };
  };

  # Prefer IPv4 in getaddrinfo source/dest selection (RFC 6724 default
  # prefers v6). ISP v6 egress has been intermittently dead — the router
  # still advertises a v6 default + hands out a global prefix, so apps dial
  # the dead v6 first and stall ~3s per attempt (wedged bun install in a nix
  # FOD). Interface-agnostic and self-healing: when v6 egress recovers, apps
  # still work, just preferring v4. mkForce overrides the stock gai.conf.
  environment.etc."gai.conf".text = lib.mkForce ''
    reload no
    precedence ::ffff:0:0/96  100
  '';

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
