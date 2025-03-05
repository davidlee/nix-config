{
  hostname,
  options,
  pkgs,
  ...
}: {
  networking = {
    networkmanager.enable = true;
    hostName = hostname;
    timeServers = options.networking.timeServers.default ++ [ "pool.ntp.org" ];

    # firewall 
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 80 443 ];
    };
    nftables.enable = true;

    
    # for tailscale:
    nameservers = [ "100.100.100.100" "8.8.8.8" "1.1.1.1" ];
    search = [ "taildcdfde.ts.net" ];
  };

  # Odin hung from Yggdrassil for nine nights
  
  services = {
    openssh = {
      enable = true;
      settings = {
        GatewayPorts = "yes";
        PasswordAuthentication = false;
        X11Forwarding = false;
        PermitRootLogin = "no";
        UseDns = true;
        # LogLevel = "VERBOSE";
      };
    };

    xrdp = {
      enable = true;
      defaultWindowManager = "${pkgs.gnome-session}/bin/gnome-session";
      openFirewall = true;
    };
    
    # rustdesk-server = {
    #   enable = true;
    #   openFirewall = true;
    #   signal = {
    #     enable = true;
    #     relayHosts = [ "localhost" ];
    #   };
    # };

    gnome.gnome-remote-desktop.enable = true;

    tailscale = {
      enable = true;
    };
  };
 
  # Disable the GNOME3/GDM auto-suspend feature that cannot be disabled in GUI!
  # If no user is logged in, the machine will power down after 20 minutes.
  systemd = {
    targets = {
      sleep.enable = false;
      suspend.enable = false;
      hibernate.enable = false;
      hybrid-sleep.enable = false;
    };
  };
  
  # https://github.com/NixOS/nixpkgs/issues/361163
  systemd.services.gnome-remote-desktop = {
    wantedBy = [ "graphical.target" ];
  };
}
