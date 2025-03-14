
{ username, ... }: {

  imports = [
    ../../home/zsh.nix
    ../../home/kitty.nix
   ];
  
  home = {
    inherit username;
    homeDirectory = "/Users/${username}";
    stateVersion = "24.11";
  };

  programs.home-manager.enable = true;
 }
