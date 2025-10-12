{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    ## keyboard firmware
    dfu-util
    qmk
    dtc
  ];
}
