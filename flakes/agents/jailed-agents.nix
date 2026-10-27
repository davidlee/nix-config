# Centralised jailed LLM agent definitions.
#
# makeJailedAgent runs an agent (pi, crush, opencode, claude, codex, gemini,
# eca, zerostack, dirge; makeJailed<Name> for each) in a bubblewrap jail under
# a profile (specDev, research, offline), which sets the network, the
# persisted home and some policy defaults. Pieces with their own file:
# workspace-binds.nix (sibling repos at /workspace/<name>) and gateway-jail.nix.
#
# Model access, two ways:
#
#   Gateway mode (`gateway = { … }`; the agents template's default): no
#   provider key and no `op run`. The jail gets one gateway key, read from a
#   file by a shell builtin and forwarded over its own `--args FD`, and the
#   gateway's URL; a thin wrapper names the fix when either is missing. With
#   pi in the jail, it also binds a generated, read-only
#   `~/.pi/agent/models.json` (one provider, `llm-gateway`).
#
#   Provider keys (`apiKeys`; IMP-051 retires this): with `useOpEnv = true`
#   (the online profiles' default), the binary wraps the bwrap launch in
#   `op run --env-file=<refs>`, so 1Password resolves the op:// refs on the
#   host and injects the plaintext into the launcher's own env, where
#   `/proc/<pid>/environ` keeps them 0600 and owner-only. They are then
#   forwarded into the agent over `--args FD` (see apiKeyPassThrough). A
#   caller that already holds resolved secrets (e.g. an Emacs broker) sets
#   `useOpEnv = false; passApiKeysFromEnv = true;`: no `op run`, the same
#   forwarding.
#
#   Either way secrets never sit on disk or in argv. Those are NOT the same
#   guarantee: until 2026-08-11 keys went as `--setenv VAR "$VAR"` on the
#   bwrap command line, in plaintext in world-readable `/proc/<pid>/cmdline`
#   for the jail's whole lifetime. Off-disk is not off-limits; treat argv as
#   public.
#
# Usage:
#   makeJailedPi { profile = "specDev"; gateway = gatewayClient "pi"; }
#   makeJailedAgent { name = "foo"; agent = foo-pkg; profile = "research"; }
{
  pkgs,
  jail-nix,
  llm-agents,
  apiKeyOpRefs ? {
    DEEPSEEK_API_KEY = "op://API_KEYS/DEEPSEEK_API_KEY/credential";
    OPENROUTER_API_KEY = "op://API_KEYS/OPENROUTER_API_KEY/credential";
    MISTRAL_API_KEY = "op://API_KEYS/MISTRAL_API_KEY/credential";
    VOYAGE_API_KEY = "op://API_KEYS/VOYAGE_API_KEY/credential";
    OPENAI_API_KEY = "op://API_KEYS/OPENAI_API_KEY/credential";
    GEMINI_API_KEY = "op://API_KEYS/GEMINI_API_KEY/credential";
    JEV_API_KEY = "op://API_KEYS/JEV_API_KEY/credential";
  },
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

    # for spec-driver hook
    python3
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
  # persisted-home bind, or that bind would cover it. -try: no file, no mount.
  hostGitExcludesOptions = [
    (jail.combinators.unsafe-add-raw-args "--ro-bind-try \"$(${hostGitExcludesFile})\" ~/.config/git/ignore")
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

  # Always applied — not policy-bearing
  baseJailOptions = with jail.combinators; [
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
  # jail may override; useOpEnv is off for offline (no network = no API
  # calls = no secrets).
  profiles = {
    specDev = {
      network = true;
      home = "agent";
      sandboxGitIdentity = true;
      useOpEnv = true;
    };

    research = {
      network = true;
      home = "agent-research";
      sandboxGitIdentity = false;
      useOpEnv = true;
    };

    offline = {
      network = false;
      home = "agent-offline";
      sandboxGitIdentity = false;
      useOpEnv = false;
    };
  };

  # A profile's jail options: the persisted home `home`, then `network` iff
  # the flag is set.
  profileOptions = p: home:
    [(jail.combinators.persist-home home)]
    ++ lib.optional profiles.${p}.network jail.combinators.network;

  # Sandbox-originated commits are visually distinct
  gitIdentityOptions = with jail.combinators; [
    (set-env "GIT_AUTHOR_NAME" gitIdentity.authorName)
    (set-env "GIT_AUTHOR_EMAIL" gitIdentity.authorEmail)
    (set-env "GIT_COMMITTER_NAME" gitIdentity.committerName)
    (set-env "GIT_COMMITTER_EMAIL" gitIdentity.committerEmail)
  ];

  # Block git push over SSH
  sshGitPushBlockOptions = with jail.combinators; [
    (set-env "GIT_SSH_COMMAND" "${pkgs.writeShellScript "git-ssh-disabled" ''
      echo "git push over SSH is disabled in this sandbox" >&2
      exit 1
    ''}")
    (set-env "SSH_AUTH_SOCK" "")
    (set-env "GIT_ASKPASS" "")
  ];

  # Environment every jail gets.
  envOptions = with jail.combinators; [
    (set-env "TERM" "xterm-256color")
    (set-env "COLORTERM" "truecolor")
    (set-env "TERMINFO_DIRS" "${pkgs.ncurses}/share/terminfo")
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

  # `elf-closure-binds BINARY`: bwrap args, NUL-separated for `--args FD`,
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
  # a host without it launches anyway. Descriptor 23: clear of the key
  # descriptors, 21 and 22 (setenvsByArgsFd).
  hostDoctrineDir = "~/.local/share/doctrine/bin";
  hostDoctrineOptions = with jail.combinators; [
    (try-ro-bind (noescape hostDoctrineDir) "/run/doctrine-bin")
    (unsafe-add-raw-args "--args 23 23< <(${elfClosureBinds} ${hostDoctrineDir}/doctrine)")
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
    useOpEnv ? profiles.${profile}.useOpEnv,
    # When the caller pre-resolves op:// refs and exports plaintext into
    # the wrapper's env (e.g. Emacs broker with a per-session cache),
    # disable `useOpEnv` but keep `passApiKeysFromEnv = true` so the
    # bwrap `--args FD` forwarding still runs.
    passApiKeysFromEnv ? useOpEnv,
    # Opt-in: reach models through an LLM gateway instead of provider keys.
    # `{ keyFile; url; runDirectory; }`, all strings, exactly those:
    #   keyFile       the gateway key's path, a shell word expanded inside
    #                 double quotes at run time (so it may carry `$HOME`);
    #   url           the gateway's OpenAI-compatible base URL, not secret;
    #   runDirectory  present while the gateway runs (its RuntimeDirectory).
    # The jail gets LLM_GATEWAY_KEY (over `--args FD`) and LLM_GATEWAY_URL,
    # and no provider key: gateway plus a non-empty `apiKeys` is refused.
    # With pi in the jail, also a read-only models.json (gateway-jail.nix).
    # In a profile without network, the jail reaches the gateway through the
    # client socket and an in-jail forwarder (socket mode, DEC-076).
    gateway ? null,
    # Names from apiKeyOpRefs to resolve and/or forward for this jail.
    # None by default: each jail names the keys its agent uses (IMP-020).
    apiKeys ? [],
  }: let
    selectedApiKeys = lib.unique apiKeys;
    unknownApiKeys = lib.filter (key: !(builtins.hasAttr key apiKeyOpRefs)) selectedApiKeys;
    selectedApiKeyOpRefs = lib.genAttrs selectedApiKeys (key: apiKeyOpRefs.${key});

    # File of selected op:// refs that `op run` reads. Contents are not
    # secret (just pointers); resolved values never land in the store.
    apiKeyEnvFile = pkgs.writeText "jailed-${name}-api-keys.env" (
      lib.concatStringsSep "\n" (lib.mapAttrsToList (key: value: "${key}=${value}") selectedApiKeyOpRefs)
    );

    # Forwards each selected API key from the wrapper's env. `$VAR` is left
    # for runtime shell expansion; the `:-` guard keeps empty/unset vars
    # from breaking set -u callers.
    apiKeyArgsFd = "21";
    apiKeyPassThrough = lib.optional (selectedApiKeys != []) (
      setenvsByArgsFd apiKeyArgsFd (
        lib.mapAttrs (var: _: "\"\${${var}:-}\"") selectedApiKeyOpRefs
      )
    );

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
      baseJailOptions
      ++ workspaceBinds
      # After the deps: bwrap mounts in argv order, so the project wins
      # /workspace/<project> over a dep that shares its basename (DEC-082).
      ++ launchDirOptions mountLaunchDir
      ++ profileOptions profile homeName
      ++ lib.optionals hostDoctrine hostDoctrineOptions
      ++ hostGitExcludesOptions
      ++ envOptions
      ++ lib.optionals blockSshGitPush sshGitPushBlockOptions
      ++ lib.optionals sandboxGitIdentity gitIdentityOptions
      ++ lib.optionals exposePostgres postgresOptions
      ++ lib.optionals passApiKeysFromEnv apiKeyPassThrough
      ++ gatewayJail.options
      ++ [
        (jail.combinators.add-pkg-deps (
          commonPkgs
          ++ [
            (
              if guardGit
              then guardedGit
              else pkgs.git
            )
          ]
          ++ extraPkgs
          ++ [agent] # allow sub-agent invocation
          ++ subagentAgents # bare binaries the subagent wrappers exec
          ++ subagentPkgs # depth-guarded jailed-<name> entrypoints
        ))
      ]
      ++ extraOptions
    );

    # Outer wrapper: resolve op:// refs on the host (uses the 1Password
    # desktop app + biometric unlock via the user's PATH `op'), inject
    # plaintext into the wrapper's env, then exec the bwrap'd agent.
    # The setgid NixOS wrapper /run/wrappers/bin/op is used when present:
    # the raw binary (e.g. /run/current-system/sw/bin/op) can't reach the
    # desktop integration socket, and PATH order can't be trusted to
    # prefer the wrapper (Emacs' inherited PATH lists sw/bin first).
    # Elsewhere (darwin), `op' comes from PATH.
    outer = pkgs.writeShellScriptBin "jailed-${name}" ''
      op=/run/wrappers/bin/op
      [ -x "$op" ] || op=$(command -v op) || {
        echo "jailed-${name}: \`op' (1Password CLI) not found on PATH; cannot resolve secrets." >&2
        echo "  Either install 1password-cli or build this agent with useOpEnv = false." >&2
        exit 127
      }
      exec "$op" run --no-masking --env-file=${apiKeyEnvFile} -- \
        ${inner}/bin/jailed-${name} "$@"
    '';
  in
    assert builtins.hasAttr profile profiles || throw "Unknown jailed agent profile: ${profile}";
    assert !(lib.hasPrefix "jailed-" name) || throw "jailed-${name}: the maker adds the jailed- prefix; pass name = \"${lib.removePrefix "jailed-" name}\"";
    assert (builtins.match "[A-Za-z0-9][A-Za-z0-9._-]*" homeName != null)
    || throw "persistedHome for jailed-${name} must match [A-Za-z0-9][A-Za-z0-9._-]*: ${homeName}";
    assert (unknownApiKeys == []) || throw "Unknown API key(s) for jailed-${name}: ${lib.concatStringsSep ", " unknownApiKeys}";
    assert (subagentNames == []) || (maxSubagentDepth > 0) || throw "maxSubagentDepth must be > 0 when subagents are exposed";
    assert (gateway == null)
    || (selectedApiKeys == [])
    || throw "jailed-${name}: gateway mode carries no provider keys; drop apiKeys (${lib.concatStringsSep ", " selectedApiKeys})";
      if gateway != null
      then gatewayJail.wrap inner
      else if useOpEnv && selectedApiKeys != []
      then outer
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
    inherit agentsByName; # unjailed binaries
    inherit (jail) combinators;
    # A jail's `gateway` value for one client (DEC-059): gatewayClient "pi".
    gatewayClient = gatewayData.client;
    # pi's gateway provider for any model set: piGatewayConfig url models.
    inherit piGatewayConfig;
    # What a client outside this flake reads instead of importing gateway.nix
    # (IMP-043): the models.json a gateway jail binds, and the gateway's facts.
    piGatewayModels = piGatewayModelsFor gatewayData.url;
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
