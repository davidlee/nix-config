{
  hostname,
  options,
  ...
}: {
  networking = {
    networkmanager = {
      enable = true;
      # dns = "none";
    };

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

    resolved = {
      enable = true;
      dnssec = "true";
      domains = ["~."];
      fallbackDns = [
        # "45.90.28.0#83ab1e.dns.nextdns.io"
        # "45.90.30.0#83ab1e.dns.nextdns.io"

        # controlD bootstrap IPs
        "76.76.2.22"
        "2606:1a40::22"
      ];
      dnsovertls = "true";

      # DNS=45.90.28.0#83ab1e.dns.nextdns.io
      # DNS=2a07:a8c0::#83ab1e.dns.nextdns.io
      # DNS=45.90.30.0#83ab1e.dns.nextdns.io
      # DNS=2a07:a8c1::#83ab1e.dns.nextdns.io
      # fuck this
      extraConfig = ''
        # controlD
        # bootstrap
        #
        DNS=76.76.2.22#1qncxpyinu9.dns.controld.com
      '';
    };
  };
}
