{
  hostname,
  options,
  ...
}: {
  # Network
  networking.networkmanager.enable = true;
  networking.hostName = hostname;
  networking.timeServers = options.networking.timeServers.default ++ [ "pool.ntp.org" ];
  networking.firewall.allowedTCPPorts = [ 22 80 3000 ];
  networking.nameservers = [ "100.100.100.100" "8.8.8.8" "1.1.1.1" ];
  networking.search = [ "taildcdfde.ts.net" ];


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
  };

  services.tailscale.enable = true;
  
}
