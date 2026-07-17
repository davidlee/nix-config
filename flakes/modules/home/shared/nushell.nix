{
  pkgs,
  config,
  lib,
  ...
}: let
  # oh-my-posh's home-manager module, for oh-my-posh >=26, execs `oh-my-posh init nu`
  # on every shell startup, which itself rewrites
  # ~/.local/share/nushell/vendor/autoload/oh-my-posh.nu as a side effect. nu
  # auto-sources that file at startup, before config.nu runs. Two nu logins starting
  # close together (e.g. tmux opening several panes/windows at once) can race on that
  # write and leave a torn file, which then fails to parse before config.nu gets a
  # chance to regenerate it. Generating the init script once at build time (the
  # pre-v26 module behaviour) removes the runtime write entirely.
  ohMyPoshNuInit = pkgs.runCommand "oh-my-posh-nushell-config.nu" {} ''
    ${lib.getExe config.programs.oh-my-posh.package} init nu --config ${config.xdg.configHome}/oh-my-posh/config.json --print >> "$out"
  '';
in {
  programs = {
    nushell = {
      enable = true;
      settings = {
        show_banner = false;
      };

      # this is loaded pretty early in proceedings ...
      extraConfig = ''
        source ${ohMyPoshNuInit}
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
      # nushell integration is hand-rolled above (build-time init, no runtime write)
      enableNushellIntegration = false;
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
