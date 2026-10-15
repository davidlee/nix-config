{username, ...}: {
  imports = [../../darwin/home.nix];

  home = {
    inherit username;
    homeDirectory = "/Users/${username}";
    stateVersion = "24.11";
  };

  programs.home-manager.enable = true;
}
