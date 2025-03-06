
{
  ...
}: {

#   services.sonarr = {
#     enable = true;
#     openFirewall = true;
#   };
#   services.radarr = {
#     enable = true;
#     openFirewall = true;
#   };
#   services.readarr = {
#     enable = true;
#     openFirewall = true;
#   };
#   services.lidarr = {
#     enable = true;
#     openFirewall = true;
#   };
#   services.whisparr = {
#     enable = true;
#     openFirewall = true;
#   };
#   services.prowlarr = {
#     enable = true;
#     openFirewall = true;
#   };


nixarr = {
    enable = true;
    mediaDir = "/media";
    stateDir = "/media/.state/nixarr";

    vpn = {
      # enable = true; # WARN TODO
      # WARNING: This file must _not_ be in the config git directory
      # You can usually get this wireguard file from your VPN provider
      # wgConf = "/data/.secret/wg.conf";
    };

    jellyfin = {
      enable = true;
      # These options set up a nginx HTTPS reverse proxy, so you can access
      # Jellyfin on your domain with HTTPS
      expose.https = {
        # enable = true;
        # domainName = "your.domain.com";
        # acmeMail = "your@email.com"; # Required for ACME-bot
      };
    };

    transmission = {
      enable = true;
      # vpn.enable = true;
      # peerPort = 50000; # Set this to the port forwarded by your VPN
    };

    bazarr.enable = true;
    lidarr.enable = true;
    prowlarr.enable = true;
    radarr.enable = true;
    readarr.enable = true;
    sonarr.enable = true;
    jellyseerr.enable = true;
  };
}
