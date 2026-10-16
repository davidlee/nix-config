# The home base's direnv (DEC-031/042); everything else is a feature.
_: {
  programs = {
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
  };
}
