{username, ...}: {
  imports = [../../modules/home/darwin];

  home = {
    inherit username;
    homeDirectory = "/Users/${username}";
    stateVersion = "24.11";
  };
}
