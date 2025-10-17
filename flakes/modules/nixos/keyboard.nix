{...}: {
  flake.nixosModules.keyboard = {pkgs, ...}: {
    hardware = {
      # allow non-root write access to firmware
      keyboard.qmk.enable = true;
    };

    environment.systemPackages = with pkgs; [
      ## keyboard firmware
      qmk-udev-rules
      dfu-util
      qmk
      dtc
    ];
  };
}
