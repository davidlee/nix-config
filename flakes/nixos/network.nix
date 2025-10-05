{
  hostname,
  options,
  ...
}: {
  networking = {
    # networkmanager = {
    #   enable = true;
    #   dns = "none";
    # };

    hostName = hostname;
    timeServers = options.networking.timeServers.default ++ ["pool.ntp.org"];

    useDHCP = false;
    dhcpcd.enable = false;

    # nextdns
    # nameservers = [
    #   "45.90.28.0#83ab1e.dns.nextdns.io"
    #   "2a07:a8c0::#83ab1e.dns.nextdns.io"
    #   "45.90.30.0#83ab1e.dns.nextdns.io"
    #   "2a07:a8c1::#83ab1e.dns.nextdns.io"
    # ];

    # firewall
    firewall = {
      enable = true;
      allowedTCPPorts = [22 80 443];
    };

    nftables.enable = true;

    # for tailscale (disabled)
    # nameservers = ["100.100.100.100" "1.1.1.1"];
    # search = ["bandicoot-sunfish.ts.net"];
  };

  # Odin hung from Yggdrassil for nine nights

  services = {
    fail2ban.enable = true;
    openssh = {
      enable = true;
      settings = {
        GatewayPorts = "yes";
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        X11Forwarding = false;
        PermitRootLogin = "no";
        UseDns = true;
      };
    };

    # tailscale = {
    #   enable = true;
    # };

    stubby = {
      enable = true;
      settings = {
        resolution_type = "GETDNS_RESOLUTION_STUB";
        dns_transport_list = ["GETDNS_TRANSPORT_TLS"];
        tls_authentication = "GETDNS_AUTHENTICATION_REQUIRED";
        listen_addresses = ["127.0.0.1@8053" "0::1@8053"];

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
      dnssec = "allow-downgrade";
      domains = ["~."];

      extraConfig = ''
        # use stubby for DoT
        [Resolve]
        DNS=127.0.0.1:8053
        DNSOverTLS=no
      '';
    };
  };
}
