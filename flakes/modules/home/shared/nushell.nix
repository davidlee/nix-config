{pkgs, ...}: {
  programs = {
    nushell = {
      enable = true;
      settings = {
        show_banner = false;
      };

      # this is loaded pretty early in proceedings ...
      extraConfig = ''
        source ~/nushell/config.nu
      '';

      extraLogin = ''
        source ~/nushell/login.nu
      '';

      shellAliases = {
        _builtin_cd = "cd";
        cd = "z";
        ci = "zi";
      };
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
    };
    # this was a piece of shit to get working
    # should do something neater than a hacked version of M365Princess theme
    # but I lost enthusiasm
    oh-my-posh = {
      enable = true;
      enableNushellIntegration = true;
      enableBashIntegration = true;
      settings = builtins.fromJSON (
        builtins.readFile ../../../files/omp.custom.json
      );
    };
    eza = {
      enable = true;
      # enableNushellIntegration = true;
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

    television = {
      enable = true;
      enableNushellIntegration = true;
    };
    yazi = {
      enable = true;
      enableNushellIntegration = true;
    };
    lazygit = {
      enable = true;
      enableNushellIntegration = true;
    };

    # mise.enableNushellIntegration = true;
    keychain.enableNushellIntegration = true;
  };
}
