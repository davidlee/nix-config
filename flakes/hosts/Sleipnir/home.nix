{username, ...}: {
  imports = [
    ../../modules/home/linux

    # host config (the doctor) and the W2 exceptions (eca, chatgpt)
    ./doctor.nix
    ../../modules/home/linux/eca.nix
    ../../modules/home/linux/chatgpt.nix
  ];

  home = {
    inherit username;
    homeDirectory = "/home/${username}";
    stateVersion = "24.11";
  };

  # services.mpris-proxy.enable = true;
}
