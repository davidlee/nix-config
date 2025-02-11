{
  pkgs,
  username,
  lib,
  config,
  inputs,
  options,
  host,
  ...
}: {
  # Network
  networking.networkmanager.enable = true;
  networking.hostName = host;
  networking.timeServers = options.networking.timeServers.default ++ [ "pool.ntp.org" ];
  networking.firewall.allowedTCPPorts = [ 22 80 ];
}
