# terminal.nushell's home module; imported by features/terminal.nix.
{
  lib,
  pkgs,
  ...
}: {
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
