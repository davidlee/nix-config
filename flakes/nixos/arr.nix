{
  username,
  pkgs,
  ...
}: {

  nixarr = {
    enable = true;
    mediaDir = "/media";
    stateDir = "/media/.state/nixarr";

    # WARN no VPN setup. is it possible to get wg.conf from tailscale?

    jellyfin.enable = true;
    transmission.enable = true;
    lidarr.enable = true;
    prowlarr.enable = true;
    radarr.enable = true;
    readarr.enable = true;
    sonarr.enable = true;
    jellyseerr.enable = true;
    # bazarr.enable = true;
  };

  services = {
    nzbget = {
      enable = true;
      group = "media";
    };
    headphones = {
      enable = true;
      dataDir = "/media/music";
      group = "media";
    };
  };

  home-manager.users.${username} = {
    home.packages = with pkgs; [
      nzbget
      nzbhydra2
      sabnzbd
      pan
      plex
    ];
  };
}
