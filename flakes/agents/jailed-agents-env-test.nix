# Impure: the env-var merge of makeJailedAgent (satan:SL-027 RV-035 F-1).
# Run by `just test` with --impure and JAIL_WORKSPACE_DEPS set; pure eval
# refuses, rather than passing vacuously on an empty getEnv.
{
  pkgs,
  jail-nix,
}: let
  envDeps = builtins.getEnv "JAIL_WORKSPACE_DEPS";
  system = pkgs.stdenv.hostPlatform.system;
  agents = import ./jailed-agents.nix {
    inherit pkgs jail-nix;
    llm-agents.packages.${system} = {};
  };
  launcher = args:
    agents.makeJailedZsh (
      {
        useOpEnv = false;
        passApiKeysFromEnv = false;
        workspaceDeps = ["/nonexistent/static-dep"];
      }
      // args
    );
  envOn = launcher {};
  envOff = launcher {workspaceDepsFromEnv = false;};
in
  assert envDeps
  != ""
  || throw "jailed-agents-env: evaluate with --impure and JAIL_WORKSPACE_DEPS set (just test does)";
    pkgs.runCommand "jailed-agents-env-tests" {
      nativeBuildInputs = [pkgs.gnugrep];
    } ''
      # A bare `! cmd` never trips errexit (bash exempts negated pipelines),
      # so it cannot fail the build. Every negative assertion uses this.
      refute() {
        if "$@"; then
          echo "refute: holds, expected not to: $*" >&2
          exit 1
        fi
      }

      on=${envOn}/bin/jailed-zsh
      off=${envOff}/bin/jailed-zsh

      # The default merges the environment's deps with the static ones.
      grep -Fq -- '/nonexistent/env-dep /workspace/env-dep' "$on"
      grep -Fq -- '/nonexistent/static-dep /workspace/static-dep' "$on"

      # workspaceDepsFromEnv = false keeps the static deps and drops the env's.
      grep -Fq -- '/nonexistent/static-dep /workspace/static-dep' "$off"
      refute grep -Fq -- '/workspace/env-dep' "$off"

      touch "$out"
    ''
