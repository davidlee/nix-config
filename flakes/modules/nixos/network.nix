{
  hostname,
  options,
  ...
}: {
  services.tailscale.enable = true;

  networking = {
    networkmanager.enable = true;

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
}
