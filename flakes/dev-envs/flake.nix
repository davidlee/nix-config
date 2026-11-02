{
  description = "Personal development environments: a project's dev-tools, plus agents, forms and a jail";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # The jail library, declared by remote like the root flake's `emacs` and
    # `agents`; a read-only recipe overrides it to the in-tree checkout, so an
    # edit there lands without a push. `path:./agents` could not work: it would
    # have to resolve inside this flake's own store copy, where no such
    # directory exists (`?dir=flakes/dev-envs` and the Mac both hit it).
    agents.url = "github:davidlee/nix-config?dir=flakes/agents";

    # quotient's form-family builder. Passed in here rather than carried by
    # every project — which is the whole point of the split.
    quotient.url = "github:davidlee/quotient/v0.6.0";

    # The project whose tools this environment carries. A RELATIVE path, so the
    # lock records `path = "./stub-project"` and a store copy still resolves it.
    # Every real use overrides it, read-only:
    #   --override-input project "git+file:$(git rev-parse --show-toplevel)"
    #   --no-write-lock-file
    # Without the second flag the override is written into this lock and pins
    # one machine's checkout (ISS-006's class of bug).
    project.url = "path:./stub-project";
  };

  # `...` is not decoration: nix passes `self` and `...` too, and a strict
  # pattern fails with "called with unexpected argument 'self'".
  outputs = {
    nixpkgs,
    agents,
    quotient,
    project,
    ...
  }: let
    # bubblewrap is Linux-only, and the direnv helper refuses any other host
    # before it touches nix, so there are no Darwin outputs to define: an
    # attribute that cannot evaluate poisons `nix flake check`.
    systems = ["x86_64-linux" "aarch64-linux"];
    forAll = f: nixpkgs.lib.genAttrs systems f;

    perSystem = system: let
      pkgs = nixpkgs.legacyPackages.${system};
      inherit (pkgs) lib;

      # The jail's SANDBOX comes from here; its TOOLS come from the project.
      jailLib = agents.lib.${system}.mkJailedAgents {inherit pkgs;};

      # The producer contract, named once, so its absence says what to do
      # instead of naming an attribute path at the bottom of a stack trace.
      devTools =
        project.packages.${
          system
        }.dev-tools or (throw ''
          dev-envs: the project flake exposes no packages.${system}.dev-tools.
          The producer contract is packages.<system>.dev-tools = buildEnv { … }:
          every tool the project's gate needs.
        '');

      # $PWD is bound read-write at /workspace/<project> and the jail starts
      # there (the library's default, DEC-078). Workspace dependencies arrive
      # through JAIL_WORKSPACE_DEPS{,_RW}, the library's own mechanism.
      jail = jailLib.makeJailedPi {
        profile = "specDev";
        allowSelfAsSubagent = true;
        maxSubagentDepth = 2;
        gateway = jailLib.gatewayClient "pi";
        extraPkgs = [devTools]; # a buildEnv is ONE derivation, not a list
      };

      # A form is a delegate's world, so it carries the same tools as the jail.
      forms = jailLib.quotientFormFamily {
        inherit quotient;
        packages = [devTools];
      };
    in {
      packages = {
        inherit jail devTools;
        quotient-read = forms.read;
        quotient-write = forms.write;
      };

      # What the project's own devshell used to borrow from its jail block: the
      # agent CLI, from the same evaluation as the jail's agents — one pin.
      devShells.jail = pkgs.mkShell {
        packages = [devTools jail jailLib.unjailed.codex];
      };

      checks = {
        # The contract, executable. `packages.jail` is not the launcher: it is
        # the gateway wrapper (agents/gateway-jail.nix `wrap`), which checks the
        # gateway and `exec`s the real launcher, so the bundle sits one
        # indirection down. Follow exactly one `exec` — no loop, so a deeper
        # chain fails at the check rather than being chased.
        #
        # The inner launcher is resolved through `builtins.readFile` because a
        # store *reference* of the wrapper is not a build input: reading it
        # carries the reference in the string's context, which is what puts the
        # file in the sandbox.
        #
        # Observed on the built stub jail: the inner launcher carries
        # `--setenv PATH …:<dev-tools>/bin:…`, i.e. the bundle's own path, and
        # nothing flattens it into member paths. So the bundle is the only
        # needle the library really renders; the stub's `probe` stays as the
        # contract's fixture, not as something this check needs.
        stub = let
          launcher = "${lib.getBin jail}/bin/jailed-pi";
          execTargets =
            lib.filter (l: lib.hasPrefix "exec ${builtins.storeDir}/" l)
            (lib.splitString "\n" (builtins.readFile launcher));
          inner =
            if execTargets == []
            then ""
            else lib.elemAt (lib.splitString " " (lib.head execTargets)) 1;
          needles = [devTools];
          grep = "${pkgs.gnugrep}/bin/grep";
        in
          pkgs.runCommand "dev-envs-stub-check" {} ''
            launcher=${launcher}
            inner=${inner}
            files=("$launcher")
            if [[ -n $inner && -f $inner ]]; then files+=("$inner"); fi
            for needle in ${lib.concatMapStringsSep " " (n: "'${n}'") needles}; do
              for f in "''${files[@]}"; do
                if ${grep} -qF -- "$needle" "$f"; then
                  touch $out
                  exit 0
                fi
              done
            done
            echo "dev-envs: the project's dev-tools never reached the jail's launcher" >&2
            echo "  looked for: ${lib.concatMapStringsSep " " toString needles}" >&2
            exit 1
          '';

        # The only static guard on the forms' bwrap line, which must stay plain
        # words: anything quotient cannot resolve without running it fails here.
        quotient-forms = quotient.lib.checkFormFamily {
          inherit pkgs;
          family = forms;
        };
      };
    };
  in {
    packages = forAll (system: (perSystem system).packages);
    devShells = forAll (system: (perSystem system).devShells);
    checks = forAll (system: (perSystem system).checks);
  };
}
