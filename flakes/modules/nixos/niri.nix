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

    # DMS
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
    inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
  security.pam.services.swaylock = {};
}
