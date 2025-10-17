{...}: {
  flake.nixosModules.apps = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      ## util
      _1password-gui
      flameshot
      # virt-viewer
      # upscayl
      # evince
      # persepolis
      # qbittorrent
      # calibre
      # ventoy-full
      # artha
      # guvcview
      # inxi
      # easyeffects
      # barrier
    ];
  };
}
