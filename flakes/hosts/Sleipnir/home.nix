{username, ...}: {
  imports = [
    ../../modules/home/linux

    # host config and W2 exceptions; the personal modules leave in SL-008 P5
    ../../modules/home/linux/sleipnir-doctor.nix
    ../../modules/home/linux/satan.nix
    ../../modules/home/linux/satan-patcher.nix
    ../../modules/home/linux/satan-attrd.nix
    ../../modules/home/linux/eca.nix
    ../../modules/home/linux/behaviour.nix
    ../../modules/home/linux/nudge.nix
    ../../modules/home/linux/goad.nix
    ../../modules/home/linux/chatgpt.nix
  ];

  home = {
    inherit username;
    homeDirectory = "/home/${username}";
    stateVersion = "24.11";
  };

  # services.mpris-proxy.enable = true;
}
