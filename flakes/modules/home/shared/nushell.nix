{pkgs, ...}: {
  programs = {
    nushell = {
      enable = true;
      settings = {
        show_banner = false;
      };
      extraConfig = ''
        source ~/.config/nushell/custom.nu
      '';
      shellAliases = {
        s = "z";
        si = "zi";
      };

      extraLogin = ''
        # login
      '';
    };
    carapace = {
      enableNushellIntegration = true;
      enable = true;
    };
    direnv = {
      enableNushellIntegration = true;
      enable = true;
    };
    zoxide = {
      enableNushellIntegration = true;
      enable = true;
      # options = ["--cmd cd"];
    };
    oh-my-posh = {
      enable = true;
      enableNushellIntegration = true;
      enableBashIntegration = true;
      settings = builtins.fromJSON (
        builtins.readFile ../../../files/omp.custom.json
      );
      # useTheme = "/home/david/.config/custom";
      # useTheme = "M365Princess";
      # enableZshIntegration = true;
    };
    fzf = {
      enable = true;
      historyWidget.command = "";
      enableNushellIntegration = true;
    };
    broot.enableNushellIntegration = true;
    atuin = {
      enable = true;
      enableNushellIntegration = true;
      flags = ["--disable-up-arrow"];
    };
    eza.enableNushellIntegration = true;
    keychain.enableNushellIntegration = true;
    mise.enableNushellIntegration = true;
    lazygit.enableNushellIntegration = true;
    # starship = {
    #   enableNushellIntegration = true;
    #   enable = true;
    # };
    television.enableNushellIntegration = true;
    yazi.enableNushellIntegration = true;
  };
}
