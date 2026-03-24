_: {
  flake.nixosModules.sway = {pkgs, ...}: {
    programs = {
      sway = {
        enable = true;
        wrapperFeatures.gtk = true;
      };
    }; # programs

    environment.systemPackages = with pkgs; [
      sway-audio-idle-inhibit
      sway-launcher-desktop
      sway-easyfocus
      sway-overfocus
      sway-scratch
      sway-new-workspace
      sway-easyfocus
      swaylock
      swaylock-fancy
      swaynotificationcenter
      swaycwd
      swaymux
      swaycons
      swaysettings
      swayr
      swayrbar
      swayosd
      sov
      waybar
      mako
      cava
    ];
  };
}
