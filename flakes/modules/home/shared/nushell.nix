{pkgs, ...}: {
  programs = {
    nushell = {
      enable = true;
      settings = {
        show_banner = false;
      };
      extraConfig = ''
        use std/util "path add"
        path add "~/nushell"
        source ~/nushell/custom.nu
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
      enableNushellIntegration = true;
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
