{
  description = "Personal development environments: a project's dev-tools and env, in five jails, two forms and a shell";

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
    #
    # Source only (`flake = false`), evaluated by flake-compat against the
    # project's OWN flake.lock: as a flake input, an overridden project's
    # inputs are relocked under this flake (Lix 2.95.4: reusing this lock's
    # entries for the stub, or locking fresh), so its tools would be built at
    # pins it never chose (SL-023 PHASE-05 F-1; checks.project-pins).
    project = {
      url = "path:./stub-project";
      flake = false;
    };
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };

    # A pinned reference Doctrine, mounted at /run/doctrine-nix-bin in every
    # jail and form, never on PATH (DEC-109). Built locally on each lock bump.
    doctrine.url = "github:davidlee/doctrine";
  };

  # `...` is not decoration: nix passes `self` and `...` too, and a strict
  # pattern fails with "called with unexpected argument 'self'".
  outputs = {
    nixpkgs,
    agents,
    quotient,
    project,
    flake-compat,
    doctrine,
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
      devEnvLib = import ./dev-env.nix;
      jailLib = agents.lib.${system}.mkJailedAgents {inherit pkgs;};

      # The producer contract, named once, so its absence says what to do
      # instead of naming an attribute path at the bottom of a stack trace.
      projectFlake = (import flake-compat {src = project;}).outputs;
      devTools =
        projectFlake.packages.${
          system
        }.dev-tools or (throw ''
          dev-envs: the project flake exposes no packages.${system}.dev-tools.
          The producer contract is packages.<system>.dev-tools = buildEnv { … }:
          every tool the project's gate needs.
        '');

      # What the project's tools need beyond packages (DEC-114). Absent: nothing.
      inherit (jailLib) hostDevEnv;
      devEnv = devEnvLib.checkDevEnv {
        inherit lib;
        hostNames = devEnvLib.hostNames hostDevEnv;
      } (devTools.devEnv or {}); # passthru attributes sit on the derivation itself
      env = hostDevEnv.env // devEnv.env;
      envOptions = c:
        lib.mapAttrsToList c.set-env env
        ++ map (jailLib.tryFwdEnv c) devEnv.hostEnv;
      nixDoctrine = doctrine.packages.${system}.default;
      tools = [devTools] ++ hostDevEnv.packages; # a buildEnv is ONE derivation, not a list

      # What every jail shares; only the agent and its subagent graph differ.
      # $PWD is bound read-write at /workspace/<project> and the jail starts
      # there (the library's default, DEC-078). Workspace dependencies arrive
      # through JAIL_WORKSPACE_DEPS{,_RW}, the library's own mechanism.
      jail = maker: args:
        maker ({
            profile = "specDev";
            gateway = jailLib.gatewayClient "pi";
            extraPkgs = tools;
            extraOptions = envOptions jailLib.combinators;
            inherit nixDoctrine;
          }
          // args);

      # Subagent graphs are Doctrine's (doctrine:flake.nix).
      jails = {
        jailed-pi = jail jailLib.makeJailedPi {
          allowSelfAsSubagent = true;
          maxSubagentDepth = 2;
        };
        jailed-pi-research = jail jailLib.makeJailedPi {
          name = "pi-research";
          profile = "research";
          allowSelfAsSubagent = true;
        };
        jailed-claude = jail jailLib.makeJailedClaude {
          allowSelfAsSubagent = true;
          subagents = ["pi"];
          maxSubagentDepth = 2;
        };
        jailed-codex = jail jailLib.makeJailedCodex {subagents = ["claude" "pi" "codex"];};
        jailed-shell = jail jailLib.makeJailedAgent {
          name = "shell";
          agent = pkgs.zsh;
          subagents = ["pi" "claude"];
        };
      };

      # A form is a delegate's world, so it carries the same tools and env as the jails.
      forms = jailLib.quotientFormFamily {
        inherit quotient;
        packages = tools;
        options = envOptions;
        postureFlags.nixDoctrine = nixDoctrine;
      };

      # Each execs its jail; jcl skips claude's permission prompts, as Doctrine's did.
      shorthand = name: bin: flags:
        pkgs.writeShellScriptBin name ''exec ${jails.${bin}}/bin/${bin} ${flags} "$@"'';
      shorthands = [
        (shorthand "jpi" "jailed-pi" "")
        (shorthand "jcl" "jailed-claude" "--dangerously-skip-permissions")
        (shorthand "jcx" "jailed-codex" "")
        (shorthand "jsh" "jailed-shell" "")
      ];
    in {
      packages =
        jails
        // {
          inherit devTools;
          quotient-read = forms.read;
          quotient-write = forms.write;
        };

      # The jails, the unjailed agent CLIs (ahead of self-installed ones on
      # PATH, one pin with the jails) and the shorthands, with the project's env.
      devShells.default = pkgs.mkShell {
        packages = tools ++ lib.attrValues jails ++ (with jailLib.unjailed; [pi claude codex]) ++ shorthands;
        inherit env;
      };

      checks = {
        # The contract, executable, for every launcher. A jail's launcher is
        # the gateway wrapper (agents/gateway-jail.nix `wrap`), which checks the
        # gateway and `exec`s the real launcher, so the bundle sits one
        # indirection down. Follow exactly one `exec` per launcher: no loop, so
        # a deeper chain fails at the check rather than being chased.
        #
        # The inner launcher is resolved through `builtins.readFile` because a
        # store *reference* of the wrapper is not a build input: reading it
        # carries the reference in the string's context, which is what puts the
        # file in the sandbox.
        #
        # Needles, each found in the wrapper or the inner launcher: the
        # bundle's own path (nothing flattens it into member paths), the
        # project's env name (set as given) and its hostEnv name (in the
        # runtime forwarding code).
        stub = let
          # `${NAME+x}` appears only in tryFwdEnv's runtime test, so a build-time
          # `--setenv STUB_HOST_ENV` would not satisfy it.
          needles = ["${devTools}" "--setenv STUB_DEV_ENV stub" "\${STUB_HOST_ENV+x}"];
          grep = "${pkgs.gnugrep}/bin/grep";
          launcherCheck = name: jail: let
            launcher = "${lib.getBin jail}/bin/${name}";
            execTargets =
              lib.filter (l: lib.hasPrefix "exec ${builtins.storeDir}/" l)
              (lib.splitString "\n" (builtins.readFile launcher));
            inner =
              if execTargets == []
              then ""
              else lib.elemAt (lib.splitString " " (lib.head execTargets)) 1;
          in ''
            files=('${launcher}')
            if [[ -n '${inner}' && -f '${inner}' ]]; then files+=('${inner}'); fi
            for needle in ${lib.concatMapStringsSep " " (n: "'${n}'") needles}; do
              found=
              for f in "''${files[@]}"; do
                if ${grep} -qF -- "$needle" "$f"; then found=1; fi
              done
              if [[ -z $found ]]; then
                echo "dev-envs: ${name} lacks '$needle'" >&2
                failed=1
              fi
            done
          '';
        in
          pkgs.runCommand "dev-envs-stub-check" {} ''
            failed=
            ${lib.concatStringsSep "\n" (lib.mapAttrsToList launcherCheck jails)}
            if [[ -n $failed ]]; then exit 1; fi
            touch $out
          '';

        dev-env = import ./dev-env-test.nix {inherit pkgs devEnvLib hostDevEnv;};

        # The project keeps its pins: its tools are built at its own lock, not
        # at this flake's. The stub's lock pins a nixpkgs this flake does not,
        # so a consumer that relocks the project fails here. Meaningful under
        # --override-input project, as `use_dev_envs` runs it (`just test`).
        project-pins = let
          lock = builtins.fromJSON (builtins.readFile "${project}/flake.lock");
          want = lock.nodes.${lock.nodes.${lock.root}.inputs.nixpkgs}.locked.rev;
          got = devTools.nixpkgsRev;
        in
          pkgs.runCommand "dev-envs-project-pins-check" {} (
            if got == want
            then "touch $out"
            else ''
              echo "dev-envs: the project's dev-tools were built at nixpkgs ${got}, its lock pins ${want}" >&2
              exit 1
            ''
          );

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
