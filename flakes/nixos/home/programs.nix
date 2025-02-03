{
  pkgs,
  host,
  username,
  ...
}: {

  imports = [
    ./zsh.nix
    ./kitty.nix
  ];

  programs = {

    walker = {
      enable = true;
      runAsService = true;
    };
  
    direnv = {
      enable = true;
      enableZshIntegration = true; 
      enableBashIntegration = true; 
      nix-direnv.enable = true;
    };

    helix.defaultEditor = true;

    neovim = {
      enable = true;
      vimAlias = true;
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    zoxide = {
      enable = true;
      enableZshIntegration = true;
      enableNushellIntegration = true;
      options = [ 
        "--cmd cd" 
        "--hook pwd" 
      ];
    };

    nushell.enable = true;
    starship = {
      enable = true;
      enableZshIntegration = true;
      enableNushellIntegration = true;
    };
    carapace = {
      enable = true;
      enableZshIntegration = true;
      enableNushellIntegration = true;
    };

    zk.enable = true;

    zellij = {
      # enable = true;
      enableZshIntegration = true;
    };

    yazi = {
      enable = true;
      enableZshIntegration = true;
    };

    eza.enable = true;
    git.enable = true;

    skim = {
      enable = true;
      enableBashIntegration = true;
    };
       
    waybar =  {
      enable = true;
    };
  };
  
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

}
