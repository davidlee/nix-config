{ pkgs,  ... }: {
  #
  # shared home-manager programs
  #
  
  programs = {
      firefox.enable = true;
      git.enable = true;
      librewolf.enable = true;
      nushell.enable = true;
      fish.enable = true;
      cava.enable = true;
      zk.enable = true;

      # BROKEN
      # ghostty = {
      #   enable = true;
      #   enableZshIntegration = true;
      # };

      helix = {
        enable = true;
        defaultEditor = true;
      };

      direnv = {
        enable = true;
        enableZshIntegration = true; 
        enableBashIntegration = true; 
        nix-direnv.enable = true;
      };

      neovim = {
        enable = true;
        vimAlias = true;
      };

      broot = {
        enable = true;
        enableZshIntegration = true;
      };
      
      mcfly = {
        enable = true;
        enableZshIntegration = true;
      };

      skim = {
        enable = true;
        enableBashIntegration = true;
      };

      carapace = {
        enable = true;
        enableZshIntegration = true;
        enableNushellIntegration = true;
      };

      eza = {
        enable = true;
        enableZshIntegration = true;
      };

      lsd = {
        enable = true;
        enableZshIntegration = false;
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

      atuin = {
        enable = true;
        enableFishIntegration = true;
        enableNushellIntegration = true;
        flags = [ "--disable-up-arrow" ];
        settings = {
          show_tabs = false;
          style = "compact";
        };
      };

      zellij = {
        enable = true;
        enableZshIntegration = true;
        attachExistingSession = true;
        exitShellOnExit = false;
      };

      yazi = {
        enable = true;
        enableZshIntegration = true;
      };

      starship = {
        enable = true;
        enableZshIntegration = true;
        enableNushellIntegration = true;
        settings = pkgs.lib.importTOML ../files/starship.toml // {
          scan_timeout = 100;
          command_timeout = 750;
        };
      };
  };
}
