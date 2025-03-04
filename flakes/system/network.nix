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

  # Odin hung from Yggdrassil for nine nights
  
}
