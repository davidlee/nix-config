{
  hostname,
  options,
  pkgs,
  ...
}: {
  # network manager frontends
  environment.systemPackages = with pkgs; [
    nm-tray
  ];

  networking = {
    networkmanager.enable = true;
    hostName = hostname;
    timeServers = options.networking.timeServers.default ++ ["pool.ntp.org"];

    # firewall
    firewall = {
      enable = true;
      allowedTCPPorts = [22 80 443];
    };

    nftables.enable = true;

    # for tailscale (disabled)
    # nameservers = ["100.100.100.100" "1.1.1.1"];
    # search = ["bandicoot-sunfish.ts.net"];

    # nextdns
    nameservers = [
      "45.90.28.0#83ab1e.dns.nextdns.io"
      "2a07:a8c0::#83ab1e.dns.nextdns.io"
      "45.90.30.0#83ab1e.dns.nextdns.io"
      "2a07:a8c1::#83ab1e.dns.nextdns.io"
    ];
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

    tailscale = {
      enable = true;
    };

    resolved = {
      enable = true;
      dnssec = "true";
      domains = ["~."];
      fallbackDns = [
        "45.90.28.0#83ab1e.dns.nextdns.io"
        # "2a07:a8c0::#83ab1e.dns.nextdns.io"
        "45.90.30.0#83ab1e.dns.nextdns.io"
        # "2a07:a8c1::#83ab1e.dns.nextdns.io"
      ];
      dnsovertls = "true";
    };

    nextdns = {
      enable = true;
    };
  };
}
