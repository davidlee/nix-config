{
  pkgs,
  ...
}: let
  # inherit (import ../../hosts/magic/variables.nix) _host;
in {
  services = {

    kmonad.enable = true;

    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        X11Forwarding = false;
        PermitRootLogin = "prohibit-password";
        UseDns = true;
      };
    };

    printing.enable = true;

    gnome.gnome-keyring.enable = true;

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
