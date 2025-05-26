{ 
  pkgs, 
  username, 
  ...
}: {

  imports = [
    ../home/zsh.nix
    ../home/vim.nix
    ../home/programs.nix
   ];
  
  home = {
    homeDirectory = "/Users/${username}";
    stateVersion = "24.11";
  };

  programs.home-manager.enable = true;

  # home.packages = with pkgs; [ ];
}
