# Impure: the env-var merge of makeJailedAgent (satan:SL-027 RV-035 F-1).
# Run by `just test` with --impure and JAIL_WORKSPACE_DEPS and
# JAIL_WORKSPACE_DEPS_RW set; pure eval
# refuses, rather than passing vacuously on an empty getEnv.
{
  pkgs,
  jail-nix,
}: let
  envDeps = builtins.getEnv "JAIL_WORKSPACE_DEPS";
  envDepsRw = builtins.getEnv "JAIL_WORKSPACE_DEPS_RW";
  system = pkgs.stdenv.hostPlatform.system;
  agents = import ./jailed-agents.nix {
    inherit pkgs jail-nix;
    # pi is compared against (piInJail), never built
    llm-agents.packages.${system}.pi = null;
  };
  launcher = args:
    agents.makeJailedZsh (
      {
        workspaceDeps = ["/nonexistent/static-dep"];
        workspaceDepsRw = ["/nonexistent/static-rw-dep"];
      }
      // args
    );
  envOn = launcher {};
  envOff = launcher {workspaceDepsFromEnv = false;};
in
  assert envDeps
  != ""
  && envDepsRw != ""
  || throw "jailed-agents-env: evaluate with --impure and JAIL_WORKSPACE_DEPS and JAIL_WORKSPACE_DEPS_RW set (just test does)";
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

      # The default merges the environment's deps with the static ones:
      # JAIL_WORKSPACE_DEPS read-only, JAIL_WORKSPACE_DEPS_RW read-write.
      grep -Fq -- '--ro-bind /nonexistent/env-dep /workspace/env-dep' "$on"
      grep -Fq -- '--ro-bind /nonexistent/static-dep /workspace/static-dep' "$on"
      grep -Fq -- '--bind /nonexistent/env-rw-dep /workspace/env-rw-dep' "$on"
      grep -Fq -- '--bind /nonexistent/static-rw-dep /workspace/static-rw-dep' "$on"

      # workspaceDepsFromEnv = false keeps the static deps and drops both env vars'.
      grep -Fq -- '--ro-bind /nonexistent/static-dep /workspace/static-dep' "$off"
      grep -Fq -- '--bind /nonexistent/static-rw-dep /workspace/static-rw-dep' "$off"
      refute grep -Fq -- '/workspace/env-dep' "$off"
      refute grep -Fq -- '/workspace/env-rw-dep' "$off"

      touch "$out"
    ''
