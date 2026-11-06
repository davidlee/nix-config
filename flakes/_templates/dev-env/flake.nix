# Template: a project's tools, for dev-envs (SPEC-003).
#
# The project states its tools and env. dev-envs builds the rest around them:
# five jails, quotient forms, and a shell with the shorthands jpi, jcl, jcx and
# jsh. So this flake names no jail, agent, form or gateway, and has no `agents`
# or `quotient` input; keep `agents` only for production jails you deploy.
#
# Setup:
#   mv _envrc .envrc
#   git init && git add flake.nix && nix flake lock && git add flake.lock
#   direnv allow
#
# dev-envs reads tracked files only, so `git add` what the tools need.
#
# Quotient forms, if the project delegates:
#   ~/flakes/bin/dev-envs-forms   # links .quotient/forms/{read,write}
#   quotient allow                # per form; re-run both when the tools change
{
  description = "Project tools, for dev-envs";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = {nixpkgs, ...}: let
    systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin"];
    forAll = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});

    # Every tool the project's gate needs. No agents, and no Doctrine: jails and
    # shells use the host's install (DEC-128).
    tools = pkgs:
      with pkgs; [
        just
      ];
  in {
    packages = forAll (pkgs: {
      # What dev-envs builds its jails, forms and shell from, and a room's
      # `toolsPackage` in the fleet.
      dev-tools = pkgs.buildEnv {
        name = "project-dev-tools";
        paths = tools pkgs;
        ignoreCollisions = true;
        # dev-envs refuses any other key, and any name the host's env list owns
        # (agents/dev-env.nix). `outerGitDir` is for a repository above the project.
        passthru.devEnv = {
          env = {}; # set in every jail, form and shell
          hostEnv = []; # names forwarded from the launch environment when set
        };
      };

      # A room has no host binary, so a fleet repo that uses Doctrine gives it this:
      # add the input `doctrine.url = "github:davidlee/doctrine";`, and set
      # `toolsPackage = "capsule-tools"` in the fleet target.
      #
      # capsule-tools = pkgs.buildEnv {
      #   name = "project-capsule-tools";
      #   paths = tools pkgs ++ [doctrine.packages.${pkgs.stdenv.hostPlatform.system}.default];
      #   ignoreCollisions = true;
      # };
    });

    # The fallback where dev-envs does not run, such as the Mac: tools only.
    devShells = forAll (pkgs: {default = pkgs.mkShell {packages = tools pkgs;};});
  };
}
