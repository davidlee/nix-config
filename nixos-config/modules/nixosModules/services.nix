{
  pkgs,
  ...
}: let
  inherit (import ../../hosts/magic/variables.nix) _host;
in {
  services = {

    openssh.enable = true;
    xserver = {
      # videoDrivers = [ "nvidia"]; # see nvidia-drivers.nix
      # enable = true; 
      # displayManager.gdm = {
      #   enable = true;
      #   wayland = true;
      # };
      xkb = {
        layout = "us";
        variant = "";
      };
    };
    
    printing.enable = true;
    gnome.gnome-keyring.enable = true;

    # emacs.enable = true; # for emacsclient

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    locate = {
      enable = true;
      package = pkgs.plocate;
      interval = "hourly";
    };
  };
}
