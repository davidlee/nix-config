{
  pkgs,
  username,
  lib,
  config,
  inputs,
  options,
  hostname,
  ...
}: {
  # Network
  networking.networkmanager.enable = true;
  networking.hostName = hostname;
  networking.timeServers = options.networking.timeServers.default ++ [ "pool.ntp.org" ];
  networking.firewall.allowedTCPPorts = [ 22 80 ];
}
