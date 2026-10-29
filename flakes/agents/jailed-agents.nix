# Centralised jailed LLM agent definitions.
#
# makeJailedAgent runs an agent (pi, crush, opencode, claude, codex, gemini,
# eca, zerostack, dirge; makeJailed<Name> for each) in a bubblewrap jail under
# a profile (specDev, research, offline), which sets the network, the
# persisted home and some policy defaults. Pieces with their own file:
# workspace-binds.nix (sibling repos at /workspace/<name>) and gateway-jail.nix.
#
# Model access is through an LLM gateway (`gateway = { … }`; the agents
# template's default), and only that: no provider key enters a jail, and no
# `op run`. The jail gets one gateway key, read from a file by a shell
# builtin and forwarded over its own `--args FD`, and the gateway's URL; a
# thin wrapper names the fix when either is missing. With pi in the jail, it
# also binds a generated, read-only `~/.pi/agent/models.json` (one provider,
# `llm-gateway`). A jail without `gateway` reaches no model unless its agent
# signs in on its own (claude, codex). Provider keys via 1Password `op run`
# were removed in IMP-051; the card names the commit to revert for them.
#
# The key never sits on disk or in argv. Off-disk is not off-limits: until
# 2026-08-11 keys went as `--setenv VAR "$VAR"` on the bwrap command line, in
# plaintext in world-readable `/proc/<pid>/cmdline` for the jail's whole
# lifetime. Treat argv as public.
#
# Usage:
#   makeJailedPi { profile = "specDev"; gateway = gatewayClient "pi"; }
#   makeJailedAgent { name = "foo"; agent = foo-pkg; profile = "research"; }
{
  pkgs,
  jail-nix,
  llm-agents,
  gitIdentity ? {
    authorName = "Jailed agent";
    authorEmail = "jailed-agent@localhost";
    committerName = "Jailed agent";
    committerEmail = "jailed-agent@localhost";
  },
}: let
  inherit (pkgs) lib;
  inherit (pkgs.stdenv) system;
  # Every jail's bwrap starts with an EMPTY environment. `--clearenv`
  # empties only the child's: bwrap's own environ is whatever it was
  # exec'd with — the launching session's, keys included — and bwrap runs
  # as PID 1 in the jail's pid namespace, same uid, so the agent can read
  # it at /proc/1/environ. Emptying it is safe because the launcher has
  # already expanded every value bwrap needs into argv or an `--args`
  # descriptor (inherited across both execs). bwrap itself reads only
  # HOME, and only without `--chdir`, which every jail passes.
  bwrapEmptyEnv = pkgs.writeShellScriptBin "bwrap" ''
    exec ${pkgs.coreutils}/bin/env -i ${lib.getExe pkgs.bubblewrap} "$@"
  '';
  jail = jail-nix.lib.extend {
    inherit pkgs;
    bubblewrapPackage = bwrapEmptyEnv;
  };

  inherit (llm-agents.packages.${system}) pi;
  inherit (llm-agents.packages.${system}) crush;
  inherit (llm-agents.packages.${system}) opencode;
  inherit (llm-agents.packages.${system}) claude-code;
  inherit (llm-agents.packages.${system}) codex;
  inherit (llm-agents.packages.${system}) gemini-cli;
  inherit (llm-agents.packages.${system}) eca;
  zerostack = pkgs.callPackage ./zerostack.nix {};
  dirge = pkgs.callPackage ./dirge.nix {};

  # Name -> agent package. Keys match maker `name` values so a jail can
  # expose sibling agents as depth-guarded sub-agents (see `subagents`).
  # Values are lazy: `attrNames` (used for `subagents = "all"` resolution)
  # does not force them, so an unreferenced zerostack/dirge never builds.
  agentsByName = {
    inherit pi;
    inherit crush;
    inherit opencode;
    claude = claude-code;
    inherit codex;
    gemini = gemini-cli;
    inherit eca;
    inherit zerostack;
    inherit dirge;
  };

  commonPkgs = with pkgs; [
    zsh
    coreutils
    bashInteractive
    # git: added per jail, guarded or plain (see guardedGit / guardGit)
    curl
    wget
    jq
    ripgrep
    fd
    findutils
    which
    gnugrep
    pulseaudio # provides paplay; talks to PULSE_SERVER (pipewire-pulse)
    gawkInteractive
    gnused
    sd
    diffutils
    gzip
    unzip
    gnutar
    tree
    ps
    libnotify
  ];

  # git with bin/git replaced by git-guard.sh, which refuses the subcommands
  # that discard uncommitted work (stash, checkout --, reset --hard, ...).
  # A replacement, not a PATH-shadowing wrapper: each jail carries exactly
  # one git, so which one runs never depends on PATH order.
  guardedGit = pkgs.symlinkJoin {
    name = "git-guarded";
    paths = [pkgs.git];
    postBuild = ''
      rm "$out/bin/git"
      install -m755 ${pkgs.replaceVars ./git-guard.sh {git = "${pkgs.git}/bin/git";}} "$out/bin/git"
      patchShebangs "$out/bin/git"
    '';
  };

  # Prints the host's global git excludes file, resolved the way git does:
  # core.excludesFile, else $XDG_CONFIG_HOME/git/ignore. Runs on the host,
  # before bwrap, so it reads the host's config rather than the jail's.
  hostGitExcludesFile = pkgs.writeShellScript "host-git-excludes-file" ''
    ${pkgs.git}/bin/git config --global --path core.excludesFile ||
      printf '%s\n' "''${XDG_CONFIG_HOME:-$HOME/.config}/git/ignore"
  '';

  # Mount the host's excludes read-only at git's default excludes path, so
  # agents do not stage files the host user ignores. No gitconfig edit: the
  # jail's git finds it when core.excludesFile is unset. Must follow the
  # persisted-home bind, or that bind would cover it: a runtime arg, so it
  # follows every static one. -try: no file, no mount. Off the bwrap line,
  # which quotient's form check requires to be plain words (IMP-052).
  # `tryFwdEnv c NAME`: forward NAME into the jail if it is set at launch.
  # jail.nix's `try-fwd-env` puts `${NAME+…}` on the bwrap line, which
  # quotient's form check refuses (it must be plain words), so this is
  # runtime code instead: safe in a jail and in a form alike.
  tryFwdEnv = c: name:
    assert lib.isValidPosixName name || throw "tryFwdEnv: not a POSIX name: ${name}";
      c.add-runtime ''
        [ -z "''${${name}+x}" ] || RUNTIME_ARGS+=(--setenv ${name} "''$${name}")
      '';

  hostGitExcludesOptions = c: [
    (c.add-runtime ''
      RUNTIME_ARGS+=(--ro-bind-try "$(${hostGitExcludesFile})" "$HOME/.config/git/ignore")
    '')
  ];

  # This repo's gateway: its address, served models and clients. Not
  # `gateway`, which makeJailedAgent takes as an argument.
  gatewayData = import ./gateway.nix;

  # Socket mode (DEC-076, DEC-077): a jail without network reaches the
  # gateway through the relay's client socket and an in-jail forwarder on the
  # gateway's own port, so its URL is unchanged.
  gatewaySocketOptions =
    import ./gateway-forwarder.nix {
      inherit pkgs;
      inherit (jail) combinators;
    } {
      socket = gatewayData.clientSocket;
      port = gatewayData.relayPort;
    };

  # A satan-mcp client: the socket's directory, read-only. A file bind pins
  # the inode satan-mcp-start replaces (ISS-042); a writable directory lets
  # the jail replace the socket and impersonate satan-mcp.
  satanMcpOptions = with jail.combinators; [
    (try-readonly "/run/user/1000/satan/mcp")
    (try-fwd-env "XDG_RUNTIME_DIR")
    (try-fwd-env "SATAN_MCP_SOCKET")
  ];

  # pi's provider for an LLM gateway; shared with the satan-runner unit.
  piGatewayConfig = import ./pi-gateway.nix {inherit lib;};

  # The models.json pi reads in gateway mode, for a gateway at `url`.
  piGatewayModelsFor = url:
    pkgs.writeText "pi-gateway-models.json"
    (builtins.toJSON (piGatewayConfig url gatewayData.models));

  # quotient's per-call forms (`quotient help form`) for a gateway client:
  # quotient.lib.mkFormFamily with this lib's pkgs, jail-nix and pi, and the
  # gateway's URL, key and models.json merged into the caller's env, secretEnv
  # and piFiles (IMP-046). `quotient` is the flake or its lib, passed in so
  # this flake takes no quotient input. Every other arg goes to mkFormFamily.
  # The gateway is reached over TCP, so the form keeps its network. The
  # form's options are the posture (sandboxed git identity on unless
  # `postureFlags` says otherwise), then the caller's `options` (IMP-052):
  # both take the combinator set built from this lib's jail.nix pin.
  quotientFormFamily = {
    quotient,
    client ? "pi",
    postureFlags ? {},
    options ? (_: []),
    env ? {},
    secretEnv ? {},
    piFiles ? {},
    ...
  } @ args: let
    gateway = gatewayData.client client;
  in
    assert (args.network or true) || throw "quotientFormFamily: the gateway is reached over TCP; network = false would cut it off";
      (quotient.lib or quotient).mkFormFamily (
        builtins.removeAttrs args ["quotient" "client" "postureFlags"]
        // {
          inherit pkgs jail-nix;
          options = c: posture ({sandboxGitIdentity = true;} // postureFlags) c ++ options c;
          inherit (agentsByName) pi;
          env = env // {LLM_GATEWAY_URL = gateway.url;};
          secretEnv = secretEnv // {LLM_GATEWAY_KEY = ''$(< "${gateway.keyFile}")'';};
          piFiles = piFiles // {"models.json" = piGatewayModelsFor gatewayData.url;};
        }
      );

  # Always applied — not policy-bearing
  baseJailOptions = c:
    with c; [
      time-zone
      no-new-session
      # make shebangs work
      (ro-bind "${pkgs.coreutils}/bin/env" "/usr/bin/env")
    ];

  # Where the jail starts (DEC-078). On: mount the host cwd at
  # /workspace/<project> and start there. Off: bind nothing and start in
  # $HOME. --chdir is passed either way: without it bwrap reads HOME from its
  # own environment (mem.fact.bwrap.pid1-environ-leak).
  launchDirOptions = mountLaunchDir:
    with jail.combinators;
      if mountLaunchDir
      then [
        (unsafe-add-raw-args "--bind \"$PWD\" \"/workspace/$(basename \"$PWD\")\"")
        (unsafe-add-raw-args "--chdir \"/workspace/$(basename \"$PWD\")\"")
      ]
      else [(unsafe-add-raw-args "--chdir \"$HOME\"")];

  # Policy-bearing profiles. `network` is data, not caller-overridable
  # (DEC-076): the one source of the network flag. `home` names the persisted
  # home; a jail may override it (`persistedHome`). The rest are defaults a
  # jail may override.
  profiles = {
    specDev = {
      network = true;
      home = "agent";
      sandboxGitIdentity = true;
    };

    research = {
      network = true;
      home = "agent-research";
      sandboxGitIdentity = false;
    };

    offline = {
      network = false;
      home = "agent-offline";
      sandboxGitIdentity = false;
    };
  };

  # A profile's jail options: the persisted home `home`, then `network` iff
  # the flag is set.
  profileOptions = p: home:
    [(jail.combinators.persist-home home)]
    ++ lib.optional profiles.${p}.network jail.combinators.network;

  # Sandbox-originated commits are visually distinct
  gitIdentityOptions = c:
    with c; [
      (set-env "GIT_AUTHOR_NAME" gitIdentity.authorName)
      (set-env "GIT_AUTHOR_EMAIL" gitIdentity.authorEmail)
      (set-env "GIT_COMMITTER_NAME" gitIdentity.committerName)
      (set-env "GIT_COMMITTER_EMAIL" gitIdentity.committerEmail)
    ];

  # Block git push over SSH
  sshGitPushBlockOptions = c:
    with c; [
      (set-env "GIT_SSH_COMMAND" "${pkgs.writeShellScript "git-ssh-disabled" ''
        echo "git push over SSH is disabled in this sandbox" >&2
        exit 1
      ''}")
      (set-env "SSH_AUTH_SOCK" "")
      (set-env "GIT_ASKPASS" "")
    ];

  # The terminal a jail's launcher runs in. Not posture: a quotient form is
  # headless and sets TERM=dumb itself (IMP-052).
  terminalOptions = with jail.combinators; [
    (set-env "TERM" "xterm-256color")
    (set-env "COLORTERM" "truecolor")
    (set-env "TERMINFO_DIRS" "${pkgs.ncurses}/share/terminfo")
  ];

  # Environment every jail and form gets.
  envOptions = c:
    with c; [
      # Claude Code runs Bash-tool commands under `bash` or `zsh` ONLY. Its
      # auto-detection reads $SHELL and falls back to "first working zsh, then
      # bash on PATH" when $SHELL is neither — so a jailed agent lands on zsh
      # (the jail login shell) and gets non-bash semantics it does not expect.
      # The usual bite is zsh globbing: `grep --include=*.md` dies with "no
      # matches found". Pin the store path: bashInteractive is in commonPkgs,
      # but `/run/current-system` and `/bin/bash` are not jail-visible, so a
      # host-stable path would be silently ignored. Inert for non-claude agents,
      # and a bad value only falls back to auto-detection — it cannot hard-break.
      (set-env "CLAUDE_CODE_SHELL" "${pkgs.bashInteractive}/bin/bash")
      # Package-manager caches in the project, not the persisted home.
      (set-env "UV_CACHE_DIR" ".uv-cache")
    ];

  # `elf-closure-binds BINARY`: bwrap args, NUL-separated,
  # binding read-only the store paths a host-built ELF needs to run: the
  # closure of its interpreter and RUNPATH. The jail sees only its own
  # closure, and a binary built outside Nix (`cargo install`) is in none.
  # No file, or not a dynamic ELF: no output, which bwrap reads as no args.
  elfClosureBinds = pkgs.writeShellScript "elf-closure-binds" ''
    PATH=${lib.makeBinPath [pkgs.patchelf pkgs.gnused pkgs.coreutils pkgs.nix]}
    [ -f "$1" ] || exit 0
    interp=$(patchelf --print-interpreter "$1" 2>/dev/null) || exit 0
    rpath=$(patchelf --print-rpath "$1" 2>/dev/null)
    roots=$(printf '%s\n' "$interp" "''${rpath//:/$'\n'}" |
      sed -n 's|^\(/nix/store/[^/]*\).*|\1|p' | sort -u)
    [ -n "$roots" ] || exit 0
    # Without the store database (a build sandbox), the roots alone.
    # shellcheck disable=SC2086 # store paths: no whitespace
    paths=$(nix-store --query --requisites $roots 2>/dev/null) || paths=$roots
    for p in $paths; do printf '%s\0' --ro-bind-try "$p" "$p"; done
  '';

  # The host's doctrine: one binary for host and jail, so no consumer flake
  # pins a copy that lags it. It has its own install root
  # (`cargo install --root ~/.local/share/doctrine`), whose bin/ holds only
  # doctrine, and that directory is bound, read-only, at its own path:
  # - a directory, never the file. A file bind pins one inode, and
  #   `cargo install` renames a new file over it, leaving the jail on the
  #   deleted one (IMP-249). A directory bind shows the new file at once.
  # - not over ~/.cargo/bin, which would expose every host cargo install
  #   and hide the jail's own (persist-home gives it a writable ~/.cargo).
  # The store paths it links against are bound too, as found at launch: a
  # reinstall built by a different toolchain needs a relaunch. All tries, so
  # a host without it launches anyway. Runtime args, off the bwrap line
  # (IMP-052); store paths only, so argv is no exposure.
  hostDoctrineDir = "~/.local/share/doctrine/bin";
  hostDoctrineOptions = c:
    with c; [
      (try-ro-bind (noescape hostDoctrineDir) "/run/doctrine-bin")
      (add-runtime ''
        mapfile -d "" -t doctrine_binds < <(${elfClosureBinds} ${hostDoctrineDir}/doctrine)
        RUNTIME_ARGS+=("''${doctrine_binds[@]}")
      '')
      (add-path "/run/doctrine-bin")
    ];

  workspaceBindsFor = import ./workspace-binds.nix {
    inherit lib;
    inherit (jail.combinators) unsafe-add-raw-args;
  };

  # Expose host PostgreSQL unix socket
  postgresOptions = with jail.combinators; [
    (try-readwrite "/run/postgresql")
  ];

  # A bwrap raw arg that sets each `name = value` of `setenvs` inside the
  # jail, where a value is a shell expression evaluated at run time.
  #
  # The values travel over `--args FD`, NOT as `--setenv VAR "$VAR"` on
  # the bwrap command line. `/proc/<pid>/cmdline` is mode 444 and /proc is
  # routinely mounted without hidepid, so an argv-borne secret is readable
  # by EVERY process on the host for as long as the jail runs — including
  # uids that execute untrusted code, such as `nixbld*` running an upstream
  # package's build script during any `nix build`. bwrap's `--args FD`
  # parses NUL-separated arguments from a descriptor instead, so the
  # plaintext travels down an anonymous pipe: absent from argv, never
  # written to disk. jail.nix already relies on the same mechanism for its
  # runtime-closure bind args, and bwrap accepts more than one `--args`.
  #
  # The descriptor is a literal rather than `{FD}<`-allocated because bash
  # expands a command's words BEFORE performing its redirections: an
  # `--args "$FD"` sharing a line with `{FD}< <(…)` expands to the empty
  # string. Literals sit clear of bash's auto-allocation floor of 10,
  # which jail.nix's own runtime-closure `--args` already holds.
  #
  # `setenvs` must be non-empty: `printf '%s\0'` with no arguments emits a
  # single empty NUL-terminated string, which bwrap would read back as an
  # empty option and reject.
  setenvsByArgsFd = fd: setenvs:
    jail.combinators.unsafe-add-raw-args (
      "--args ${fd} ${fd}< <(printf '%s\\0'"
      + lib.concatStrings (lib.mapAttrsToList (var: value: " --setenv ${var} ${value}") setenvs)
      + ")"
    );

  # The confinement every jail and every quotient form gets (IMP-052): a
  # function of a jail.nix combinator set, so makeJailedAgent applies it to
  # jail.combinators and quotientFormFamily to mkFormFamily's `c`. It runs
  # before the launcher's options, and nothing in it depends on their order:
  # its one static mount outside the base (/run/doctrine-bin) overlaps none of
  # theirs, the excludes bind is a runtime arg (after every static one), and
  # a later add-pkg-deps prepends to PATH, so the launcher's packages still
  # come first. No default for sandboxGitIdentity: each caller chooses.
  posture = {
    sandboxGitIdentity,
    hostDoctrine ? true,
    blockSshGitPush ? true,
    guardGit ? true,
  }: c:
    baseJailOptions c
    ++ lib.optionals hostDoctrine (hostDoctrineOptions c)
    ++ hostGitExcludesOptions c
    ++ envOptions c
    ++ lib.optionals blockSshGitPush (sshGitPushBlockOptions c)
    ++ lib.optionals sandboxGitIdentity (gitIdentityOptions c)
    ++ [
      (c.add-pkg-deps (commonPkgs
        ++ [
          (
            if guardGit
            then guardedGit
            else pkgs.git
          )
        ]))
    ];

  gatewayJailFor = import ./gateway-jail.nix {
    inherit lib pkgs setenvsByArgsFd piGatewayModelsFor;
    inherit (jail) combinators;
    inherit (gatewayData) clientSocket;
    socketOptions = gatewaySocketOptions;
  };

  makeJailedAgent = {
    name,
    agent,
    profile ? "specDev",
    extraPkgs ? [],
    extraOptions ? [],
    mountLaunchDir ? true, # bind the host cwd at /workspace/<project> and start there (DEC-078)
    workspaceDeps ? [], # sibling repo paths bound read-only at /workspace/<basename> (DEC-081);
    # merged with newline/colon-separated paths from the JAIL_WORKSPACE_DEPS
    # env var (impure eval only) unless workspaceDepsFromEnv is false.
    # See workspace-binds.nix.
    workspaceDepsRw ? [], # as workspaceDeps, bound read-write; env var JAIL_WORKSPACE_DEPS_RW
    workspaceDepsFromEnv ? true, # false: ignore both env vars (satan:SL-027 RV-035 F-1)
    persistedHome ? null, # name of the persisted home; null: the profile's (satan:SL-027 RV-035 F-6)
    # Sibling agents to expose inside the jail as depth-guarded
    # `jailed-<name>` wrappers. Either a list of names from `agentsByName`
    # (e.g. [ "pi" "codex" ]) or the string "all". A nested agent runs
    # inside the existing bwrap sandbox (inherits the jail, not re-jailed).
    subagents ? [],
    # Back-compat sugar: adds this agent's own `name` to `subagents`.
    allowSelfAsSubagent ? false,
    maxSubagentDepth ? 1,
    blockSshGitPush ? true,
    sandboxGitIdentity ? profiles.${profile}.sandboxGitIdentity,
    # Swap git for guardedGit (refuses stash, checkout --, reset --hard, ...).
    guardGit ? true,
    exposePostgres ? false,
    # The host's doctrine install root, read-only (hostDoctrineOptions).
    hostDoctrine ? true,
    # Opt-in: reach models through an LLM gateway instead of provider keys.
    # `{ keyFile; url; runDirectory; }`, all strings, exactly those:
    #   keyFile       the gateway key's path, a shell word expanded inside
    #                 double quotes at run time (so it may carry `$HOME`);
    #   url           the gateway's OpenAI-compatible base URL, not secret;
    #   runDirectory  present while the gateway runs (its RuntimeDirectory).
    # The jail gets LLM_GATEWAY_KEY (over `--args FD`) and LLM_GATEWAY_URL,
    # and no provider key.
    # With pi in the jail, also a read-only models.json (gateway-jail.nix).
    # In a profile without network, the jail reaches the gateway through the
    # client socket and an in-jail forwarder (socket mode, DEC-076).
    gateway ? null,
  }: let
    # pi is in the jail as the agent (makeJailedPi, whatever its `name`,
    # e.g. pi-research) or as a subagent. Derivations compare by output path.
    piInJail = agent == pi || lib.elem "pi" subagentNames;

    gatewayJail = gatewayJailFor {
      inherit name gateway piInJail;
      inherit (profiles.${profile}) network;
    };

    # Resolve a subagent name to its package. The current agent is
    # reachable under its own `name` even for custom (non-map) agents.
    resolveAgent = n:
      if n == name
      then agent
      else agentsByName.${n} or (throw "Unknown subagent for jailed-${name}: ${n}");

    # Names of sibling agents to expose, deduped. "all" => every entry in
    # agentsByName; allowSelfAsSubagent folds the agent's own name in.
    subagentNames = lib.unique (
      (
        if subagents == "all"
        then lib.attrNames agentsByName
        else subagents
      )
      ++ lib.optional allowSelfAsSubagent name
    );

    # Depth-guarded entrypoint for one sub-agent. Shares a single
    # JAILED_AGENT_DEPTH counter across all agents, so total nesting depth
    # (claude -> pi -> codex -> ...) is bounded regardless of which agents
    # are chained.
    mkSubagentPkg = subName:
      pkgs.writeShellScriptBin "jailed-${subName}" ''
        depth="''${JAILED_AGENT_DEPTH:-0}"

        if [ "$depth" -ge "${toString maxSubagentDepth}" ]; then
          echo "jailed-${subName}: maximum sub-agent depth (${toString maxSubagentDepth}) reached" >&2
          exit 1
        fi

        export JAILED_AGENT_DEPTH="$((depth + 1))"
        exec ${lib.getExe (resolveAgent subName)} "$@"
      '';

    subagentPkgs = map mkSubagentPkg subagentNames;
    # Bare binaries for sibling agents (the wrapper execs them); the
    # current agent is already added below, so exclude it here.
    subagentAgents = map resolveAgent (lib.filter (n: n != name) subagentNames);
    # The name is spliced unescaped into a path and into the launcher's shell.
    homeName =
      if persistedHome == null
      then profiles.${profile}.home
      else persistedHome;
    workspaceBinds = workspaceBindsFor {
      inherit name;
      ro = workspaceDeps;
      rw = workspaceDepsRw;
      fromEnv = workspaceDepsFromEnv;
    };

    inner = jail "jailed-${name}" agent (
      posture {inherit sandboxGitIdentity hostDoctrine blockSshGitPush guardGit;} jail.combinators
      ++ workspaceBinds
      # After the deps: bwrap mounts in argv order, so the project wins
      # /workspace/<project> over a dep that shares its basename (DEC-082).
      ++ launchDirOptions mountLaunchDir
      ++ profileOptions profile homeName
      ++ terminalOptions
      ++ lib.optionals exposePostgres postgresOptions
      ++ gatewayJail.options
      ++ [
        (jail.combinators.add-pkg-deps (
          extraPkgs
          ++ [agent] # allow sub-agent invocation
          ++ subagentAgents # bare binaries the subagent wrappers exec
          ++ subagentPkgs # depth-guarded jailed-<name> entrypoints
          # malebolge-bridge (satan SL-009, DEC-075) is a node script run with
          # type stripping (node >= 23.6), wherever pi runs.
          ++ lib.optional piInJail pkgs.nodejs_24
        ))
      ]
      ++ extraOptions
    );
  in
    assert builtins.hasAttr profile profiles || throw "Unknown jailed agent profile: ${profile}";
    assert !(lib.hasPrefix "jailed-" name) || throw "jailed-${name}: the maker adds the jailed- prefix; pass name = \"${lib.removePrefix "jailed-" name}\"";
    assert (builtins.match "[A-Za-z0-9][A-Za-z0-9._-]*" homeName != null)
    || throw "persistedHome for jailed-${name} must match [A-Za-z0-9][A-Za-z0-9._-]*: ${homeName}";
    assert (subagentNames == []) || (maxSubagentDepth > 0) || throw "maxSubagentDepth must be > 0 when subagents are exposed";
      if gateway != null
      then gatewayJail.wrap inner
      else inner;

  # makeJailed<Name> for each agent: makeJailedAgent with that name and
  # package. zsh is for testing and installation.
  capitalise = s: lib.toUpper (builtins.substring 0 1 s) + builtins.substring 1 (-1) s;
  makers =
    lib.mapAttrs' (
      name: agent:
        lib.nameValuePair "makeJailed${capitalise name}" (args: makeJailedAgent ({inherit name agent;} // args))
    )
    (agentsByName // {inherit (pkgs) zsh;});
in
  makers
  // {
    inherit makeJailedAgent;
    # The shared confinement: posture { sandboxGitIdentity; … } combinators.
    inherit posture;
    # Env forwarding that a quotient form accepts: tryFwdEnv combinators NAME.
    inherit tryFwdEnv;
    # Checks that no jail reaches a path: mkJailScanCheck { … }, and its op
    # preset, opUnjailed launchers (jail-scan.nix).
    inherit (import ./jail-scan.nix {inherit lib pkgs;}) mkJailScanCheck opUnjailed;
    inherit agentsByName; # unjailed binaries
    inherit (jail) combinators;
    # A jail's `gateway` value for one client (DEC-059): gatewayClient "pi".
    gatewayClient = gatewayData.client;
    # pi's gateway provider for any model set: piGatewayConfig url models.
    inherit piGatewayConfig;
    # What a client outside this flake reads instead of importing gateway.nix
    # (IMP-043): the models.json a gateway jail binds, and the gateway's facts.
    piGatewayModels = piGatewayModelsFor gatewayData.url;
    inherit quotientFormFamily;
    # The base tools every jail carries; a form adds them itself.
    inherit commonPkgs;
    gatewayFacts = {inherit (gatewayData) url clientSocket relayPort models;};
    # Socket mode for a jail without `gateway` (e.g. a key-file client), via
    # `extraOptions`; refused at evaluation in a jail sharing the host netns.
    inherit gatewaySocketOptions;
    # A satan-mcp client's bind and env, via `extraOptions`.
    inherit satanMcpOptions;
    # Bare (unjailed) agent packages, resolved from the same eval as the
    # jails (same nixpkgs/llm-agents pin). Lets the host devShell pull
    # `unjailed.pi` etc. without separately wiring llm-agents.
    unjailed = agentsByName;
  }
