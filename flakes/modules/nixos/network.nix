{
  hostname,
  options,
  ...
}: {
  networking = {
    networkmanager.enable = true;

    hostName = hostname;
    timeServers = options.networking.timeServers.default ++ ["pool.ntp.org"];

    useDHCP = false;
    dhcpcd.enable = false;

    firewall.enable = true;

    nftables.enable = true;
  };
}
