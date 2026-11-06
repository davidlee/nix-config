# Behaviour tests for the flake templates. `lib.runTests` returns [] when every
# test passes; perSystem.nix runs this as checks.<system>.templates (`just test`).
{
  nixpkgs,
  pkgs,
}: let
  inherit (pkgs) lib;
  inherit (pkgs.stdenv.hostPlatform) system;

  flake = name: import (./_templates + "/${name}/flake.nix");
  outputs = name: (flake name).outputs {inherit nixpkgs;};
  shell = name: (outputs name).devShells.${system}.default;
  evaluates = drv: lib.isString drv.drvPath;

  devTools = (outputs "dev-env").packages.${system}.dev-tools;
  devEnv = import ./dev-envs/dev-env.nix;
in
  lib.runTests {
    # dev-envs refuses what the producer contract refuses (SPEC-003).
    testDevEnvMeetsTheProducerContract = {
      expr =
        devEnv.errors {
          inherit lib;
          hostNames = devEnv.hostNames ((import ./agents/dev-env.nix).for pkgs);
        }
        devTools.devEnv;
      expected = [];
    };

    testDevEnvExportsToolsAndFallbackShell = {
      expr = map evaluates [devTools (shell "dev-env")];
      expected = [true true];
    };

    # Jails, forms and agents are dev-envs': no project names them (DEC-111).
    testDevEnvTakesNoAgentInputs = {
      expr = lib.attrNames (flake "dev-env").inputs;
      expected = ["nixpkgs"];
    };

    testMinimalShellFromFlake = {
      expr = evaluates (shell "minimal");
      expected = true;
    };

    testMinimalShellFromShellNix = {
      expr = evaluates (import ./_templates/minimal/shell.nix {inherit pkgs;});
      expected = true;
    };
  }
