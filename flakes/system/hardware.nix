{ pkgs, ... }: {
  hardware = {
    steam-hardware.enable = true;
    # bluetooth = {
    #   # enable = true;
    #   # powerOnBoot = true;
    # };
    # logitech.wireless = {
    #   enable = false;
    #   enableGraphical = false;
    # };
    keyboard.qmk.enable = true;
  };
}
