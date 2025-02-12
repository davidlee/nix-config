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

    # walker = {
    #   enable = true;
    #   runAsService = true;
    # };
    # 
    # waybar =  {
    #   enable = true;
    # };

  
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

    carapace = {
      enable = true;
      enableZshIntegration = true;
      enableNushellIntegration = true;
    };

    zk.enable = true;
    nushell.enable = true;
    eza.enable = true;
    git.enable = true;

    zellij = {
      # enable = true;
      enableZshIntegration = true;
    };

    yazi = {
      enable = true;
      enableZshIntegration = true;
    };


    skim = {
      enable = true;
      enableBashIntegration = true;
    };
       
    firefox.enable = true;

    starship = {
      enable = true;
      enableZshIntegration = true;
      enableNushellIntegration = true;
      settings = {
        add_newline = false;
        buf = {symbol = " ";};
        c = {symbol = " ";};
        directory = {read_only = " 󰌾";};
        docker_context = {symbol = " ";};
        fossil_branch = {symbol = " ";};
        git_branch = {symbol = " ";};
        golang = {symbol = " ";};
        hg_branch = {symbol = " ";};
        hostname = {ssh_symbol = " ";};
        lua = {symbol = " ";};
        memory_usage = {symbol = "󰍛 ";};
        meson = {symbol = "󰔷 ";};
        nim = {symbol = "󰆥 ";};
        nix_shell = {symbol = " ";};
        nodejs = {symbol = " ";};
        ocaml = {symbol = " ";};
        package = {symbol = "󰏗 ";};
        python = {symbol = " ";};
        rust = {symbol = " ";};
        swift = {symbol = " ";};
        zig = {symbol = " ";};
      };
    };

  };
  
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
