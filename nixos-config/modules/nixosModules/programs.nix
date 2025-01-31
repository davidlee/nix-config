{pkgs, ...}: {
  programs = {
    # thunderbird.enable = true;
    firefox.enable = true;

    starship = {
      enable = true;
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

    nix-ld.enable = true;
    
    dconf.enable = true;
    
    hyprland = { 
      enable = true; 
      withUWSM = true;
    };

    zsh.enable = true;

    steam = {
      enable = true;
      # gamescopeSession.enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true; 
    };
    thunar = {
      enable = true;
      plugins = with pkgs.xfce; [thunar-archive-plugin thunar-volman];
    };
  };
}
