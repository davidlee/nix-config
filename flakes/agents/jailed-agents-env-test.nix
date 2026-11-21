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
    # A stand-in pi: makeJailedPi builds it into a launcher, never runs it.
    llm-agents.packages.${system}.pi = pkgs.writeShellScriptBin "pi" "exit 0";
    zmx = pkgs.writeShellScriptBin "zmx" "exit 0";
    zmx-new = pkgs.writeShellScriptBin "zmx-new" "exit 0";
    inherit (import ./test-fixtures.nix {inherit pkgs jail-nix;}) zmxHarness;
  };
  launcherOf = maker: args:
    maker (
      {
        workspaceDeps = ["/nonexistent/static-dep"];
        workspaceDepsRw = ["/nonexistent/static-rw-dep"];
      }
      // args
    );
  launcher = launcherOf agents.makeJailedZsh;
  envOn = launcher {};
  envOff = launcher {workspaceDepsFromEnv = false;};
  # pi, so the malebolge bridge is attached by default (nemesis:DEC-237).
  integrationsOn = launcherOf agents.makeJailedPi {};
  integrationsOff = launcherOf agents.makeJailedPi {hostIntegrations = false;};
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

      # hostIntegrations = false (nemesis:DEC-237) drops all four host
      # integrations, which the default carries: the env vars' deps, the
      # malebolge bridge, the host git excludes and the zmx state relay. The
      # declared deps stay.
      pi_on=${integrationsOn}/bin/jailed-pi
      pi_off=${integrationsOff}/bin/jailed-pi
      for marker in /workspace/env-dep /workspace/env-rw-dep malebolge \
        -host-git-excludes-file ZMX_SESSION; do
        grep -Fq -- "$marker" "$pi_on"
        refute grep -Fq -- "$marker" "$pi_off"
      done
      grep -Fq -- '--ro-bind /nonexistent/static-dep /workspace/static-dep' "$pi_off"
      grep -Fq -- '--bind /nonexistent/static-rw-dep /workspace/static-rw-dep' "$pi_off"

      touch "$out"
    ''
