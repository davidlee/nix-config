{
  description = "The producer contract's smallest executable form: packages.<system>.dev-tools";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs = {nixpkgs, ...}: let
    systems = ["x86_64-linux" "aarch64-linux"];
    forAll = f: nixpkgs.lib.genAttrs systems (s: f nixpkgs.legacyPackages.${s});
  in {
    packages = forAll (pkgs: {
      dev-tools = pkgs.buildEnv {
        name = "stub-dev-tools";
        paths = [pkgs.hello];
        passthru = {
          devEnv = {
            env.STUB_DEV_ENV = "stub";
            hostEnv = ["STUB_HOST_ENV"];
            # A declared jail, shaped as nemesis:SL-026's probe: dev-envs
            # builds it as jailed-probe (checks.declared-jail).
            jails.probe = {
              agent = "pi";
              network = "offline";
              mounts = [
                {
                  from = "tools/probe";
                  to = "/probe";
                  mode = "ro";
                }
                {
                  from = "tools/probe/pi-mcp.json";
                  to = "~/.pi/agent/mcp.json";
                  mode = "ro";
                }
                {
                  from = "$PROBE_SESSION_DIR";
                  to = "/session";
                  mode = "rw";
                }
                {
                  from = "$XDG_RUNTIME_DIR/nemesis-probe";
                  to = "/run/probe";
                  mode = "ro";
                }
              ];
              forwards = [
                {
                  port = 7000;
                  socket = "/run/probe/duel.sock";
                }
              ];
            };
          };
          # Which nixpkgs built these tools: checks.project-pins compares it
          # with this flake's own lock.
          nixpkgsRev = nixpkgs.rev;
        };
      };
      probe = pkgs.hello; # the same derivation, named for the check
    });
    devShells = forAll (pkgs: {default = pkgs.mkShell {packages = [pkgs.hello];};});
  };
}
