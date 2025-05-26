{ username, ... }: {

  imports = [
    ../../home/zsh.nix
    ../../home/vim.nix
    ../../home/programs.nix
   ];
  
  home = {
    username = "${username}";
    homeDirectory = "/home/${username}";
    stateVersion = "24.11";
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  programs.home-manager.enable = true;
}
