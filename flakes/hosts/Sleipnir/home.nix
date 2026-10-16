{username, ...}: {
  imports = [
    ../../modules/home/linux

    # host config
    ./doctor.nix
  ];

  home = {
    inherit username;
    homeDirectory = "/home/${username}";
    stateVersion = "24.11";
  };

  # services.mpris-proxy.enable = true;
}
