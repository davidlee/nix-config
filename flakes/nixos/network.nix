{
  hostname,
  options,
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
    nameservers = [ "100.100.100.100" "1.1.1.1" ];
    search = [ "bandicoot-sunfish.ts.net" ];
  };

  # Odin hung from Yggdrassil for nine nights
  
  programs.ssh.startAgent = true;

  services = {
    openssh = {
      enable = true;
      settings = {
        GatewayPorts = "yes";
        PasswordAuthentication = false;
        X11Forwarding = false;
        PermitRootLogin = "no";
        UseDns = true;
      };
    };

    tailscale = {
      enable = true;
    };
  };
}
