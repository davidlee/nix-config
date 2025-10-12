{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    ## daw & audio
    # carla # BROKEN (pyliblo)
    reaper
    bitwig-studio
    renoise
    # lmms # BROKEN
    # zrythm # BROKEN
    # ardour
    # hydrogen
    # audacity
    # yoshimi
    # qtractor
    # rakarrack
    # guitarix
    # supercollider-with-plugins
    # chuck
    vcv-rack
    cardinal
    helm
  ];
}
