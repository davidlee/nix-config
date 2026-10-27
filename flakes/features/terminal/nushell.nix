# terminal.nushell's home module; imported by features/terminal.nix.
{
  lib,
  pkgs,
  config,
  ...
}: let
  omp = config.programs.oh-my-posh;
  # Where nu looks for vendor autoloads: its data dir on Linux, and on darwin.
  ompAutoloads =
    map (d: "${d}/nushell/vendor/autoload/oh-my-posh.nu")
    [config.xdg.dataHome "${config.home.homeDirectory}/Library/Application Support"];
in {
  # oh-my-posh's nu integration runs `oh-my-posh init nu` at every start,
  # which writes its prompt script into nu's vendor autoload. Nothing removes
  # it, so with the integration off nu would still load it, with no config:
  # oh-my-posh's default theme. Remove it whenever the integration is off.
  home.activation.removeOhMyPoshNuScript =
    lib.mkIf (!(omp.enable && omp.enableNushellIntegration))
    (lib.hm.dag.entryAfter ["writeBoundary"] ''
      run rm -f ${lib.escapeShellArgs ompAutoloads}
    '');

  programs = {
    nushell = {
      enable = true;
      # HACK: bridge nix-darwin's POSIX PATH setup into a direct Nu login.
      # Nu does not source /etc/profile; env.nu must add Nix paths before
      # vendor hooks/config.nu run. This is an integration gap, not an OS bug.
      # Revisit if nix-darwin/Home Manager provides native Nu PATH setup;
      # remove only after a fresh login finds atuin/zoxide without this block.
      extraEnv = lib.mkIf pkgs.stdenv.isDarwin ''
        $env.PATH = ([
          ($env.HOME | path join ".nix-profile" "bin")
          "/run/current-system/sw/bin"
          "/nix/var/nix/profiles/default/bin"
        ] | append $env.PATH | uniq)
      '';
      # nu can't source hm-session-vars.sh, so pass home.sessionVariables directly
      # environmentVariables = config.home.sessionVariables; # deprecated
      loadSessionVariables = true;
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
    fish.enable = true; # for nu completions
  };
}
