{
  pkgs,
  inputs,
  ...
}: {
  programs = {
    niri = {
      enable = true;
      useNautilus = true;
    };

    # dms-shell = {
    #   enable = true;
    #   # plugins
    #   enableDynamicTheming = true;
    #   enableCalendarEvents = true;
    #   enableAudioWavelength = true;
    #   enableClipboardPaste = true;
    #
    #   systemd.enable = true;
    # };
  }; # programs
  environment.systemPackages = with pkgs; [
    xwayland-satellite
    stasis
    # inputs.niri-float-sticky.packages.${system}.niri-float-sticky
  ];
  security.pam.services.swaylock = {};
}
