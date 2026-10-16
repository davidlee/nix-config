{
  pkgs,
  lib,
  ...
}: {
  programs = {
    nix-search-tv.enableTelevisionIntegration = true;

    direnv = {
      enable = true;
      silent = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      enableNushellIntegration = true;
      nix-direnv.enable = true;
      # `use flake_local <input>[:<dir>]... [args]`: `use flake .`, but each
      # named input is read live from ~/flakes/<dir> (default: the input's
      # name) rather than the project's flake.lock, so a bump there reaches
      # every project on its next reload. Leading words name inputs; the rest
      # pass to `use flake`. An input whose checkout is absent keeps its lock.
      # `use flake_pub` serves consumers whose input is still called `pub`
      # (flakes/pub is now a shim; this points them at flakes/agents).
      # Template: ~/flakes/_templates/agents/_envrc.
      stdlib = ''
        use_flake_local() {
          local args=() name dir
          while [[ $# -gt 0 && $1 != -* ]]; do
            name=''${1%%:*}
            dir="$HOME/flakes/''${1#*:}"
            if [[ -d $dir ]]; then
              args+=(--override-input "$name" "path:$dir")
              watch_file "$dir/flake.lock" "$dir"/*.nix
            else
              log_status "flake_local: no $dir; $name from lock"
            fi
            shift
          done
          use flake . "''${args[@]}" "$@"
        }
        use_flake_pub() { use_flake_local pub:agents "$@"; }
      '';
    };

    yazi = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      enableNushellIntegration = true;
      plugins = with pkgs.yaziPlugins; {
        lazygit.package = lazygit;
        jjui.package = jjui;
        glow.package = glow;
        wl-clipboard.package = wl-clipboard;
        # Plugins that don't call setup() can be configured in one line
        smart-enter.package = smart-enter;
        chmod.package = chmod;

        # Yatline-Catppuccin needs to be setup into a variable later
        yatline-catppuccin.package = yatline-catppuccin;

        yatline = {
          package = yatline;
          setup = true;
          settings = {
            tab_width = 20;
            # Return as lua code
            theme = lib.mkLuaInline ''
              require("yatline-catppuccin"):setup("mocha")
            '';
          };
        };
      };
      shellWrapperName = "y";
    };
  };
}
