# Centralised jailed LLM agent definitions.
#
# Each agent (pi, crush, opencode, claude, codex, gemini) can run under any sandbox profile.
# Profiles control persistence, networking, and policy defaults;
# agent wrappers remain thin.
#
# Secret injection:
#   When `useOpEnv = true` (default for online profiles), the resulting
#   binary wraps the bwrap launch in `op run --env-file=<refs>` so
#   1Password resolves API key op:// refs on the host (with biometric /
#   desktop unlock) and injects the plaintext values into the bwrap
#   process env. The values are then forwarded through bwrap into the
#   agent via `--setenv VAR "$VAR"`. Secrets never sit on disk; they
#   live only in the bwrap process env for the agent's lifetime.
#
# Usage:
#   makeJailedPi { profile = "specDev"; extraPkgs = [ go ]; }
#   makeJailedAgent { name = "foo"; agent = foo-pkg; profile = "research"; }
{
  pkgs,
  jail-nix,
  llm-agents,
  apiKeyOpRefs ? {
    DEEPSEEK_API_KEY   = "op://API_KEYS/DEEPSEEK_API_KEY/credential";
    OPENROUTER_API_KEY = "op://API_KEYS/OPENROUTER_API_KEY/credential";
    MISTRAL_API_KEY    = "op://API_KEYS/MISTRAL_API_KEY/credential";
    VOYAGE_API_KEY     = "op://API_KEYS/VOYAGE_API_KEY/credential";
    OPENAI_API_KEY     = "op://API_KEYS/OPENAI_API_KEY/credential";
    GEMINI_API_KEY     = "op://API_KEYS/GEMINI_API_KEY/credential";
  },
}: let
  inherit (pkgs) lib;
  inherit (pkgs.stdenv) system;
  jail = jail-nix.lib.init pkgs;

  # File of op:// refs that `op run` reads. Contents are not secret
  # (just pointers); the resolved values never land in the store.
  apiKeyEnvFile = pkgs.writeText "llm-api-keys.env"
    (lib.concatStringsSep "\n"
      (lib.mapAttrsToList (k: v: "${k}=${v}") apiKeyOpRefs));

  # bwrap raw args forwarding each API key from the wrapper's env into
  # the jailed agent. `$VAR` is left for runtime shell expansion; the
  # `:-` guard keeps empty/unset vars from breaking set -u callers.
  apiKeyPassThrough =
    lib.mapAttrsToList
      (var: _:
        jail.combinators.unsafe-add-raw-args
          ''--setenv ${var} "''${${var}:-}"'')
      apiKeyOpRefs;

  inherit (llm-agents.packages.${system}) pi;
  inherit (llm-agents.packages.${system}) crush;
  inherit (llm-agents.packages.${system}) opencode;
  inherit (llm-agents.packages.${system}) claude-code;
  inherit (llm-agents.packages.${system}) codex;
  inherit (llm-agents.packages.${system}) gemini-cli;
  zerostack = pkgs.callPackage ./zerostack.nix {};

  commonPkgs = with pkgs; [
    zsh
    coreutils
    bashInteractive
    git
    curl
    wget
    jq
    ripgrep
    fd
    findutils
    which
    gnugrep
    gawkInteractive
    gnused
    sd
    diffutils
    gzip
    unzip
    gnutar
    tree
    ps

    # for spec-driver hook
    python3
  ];

  # Always applied — not policy-bearing
  baseJailOptions = with jail.combinators; [
    time-zone
    no-new-session
    # Mount host cwd at /workspace/<project> and start there
    (unsafe-add-raw-args "--bind \"$PWD\" \"/workspace/$(basename \"$PWD\")\"")
    (unsafe-add-raw-args "--chdir \"/workspace/$(basename \"$PWD\")\"")
  ];

  # Policy-bearing options keyed by profile name
  profileOptions = {
    specDev = with jail.combinators; [
      (persist-home "agent")
      network
    ];

    research = with jail.combinators; [
      (persist-home "agent-research")
      network
    ];

    offline = with jail.combinators; [
      (persist-home "agent-offline")
    ];
  };

  # Per-profile boolean defaults for git controls + op env injection.
  # useOpEnv is off for offline (no network = no API calls = no secrets).
  profileDefaults = {
    specDev = {
      blockGitPush = true;
      sandboxGitIdentity = true;
      exposePostgres = false;
      useOpEnv = true;
    };

    research = {
      blockGitPush = true;
      sandboxGitIdentity = false;
      exposePostgres = false;
      useOpEnv = true;
    };

    offline = {
      blockGitPush = true;
      sandboxGitIdentity = false;
      exposePostgres = false;
      useOpEnv = false;
    };
  };

  # Sandbox-originated commits are visually distinct
  gitIdentityOptions = with jail.combinators; [
    (set-env "GIT_AUTHOR_NAME" "clanker")
    (set-env "GIT_AUTHOR_EMAIL" "clanker@local")
    (set-env "GIT_COMMITTER_NAME" "clanker")
    (set-env "GIT_COMMITTER_EMAIL" "clanker@local")
  ];

  # Block git push over SSH
  gitPushBlockOptions = with jail.combinators; [
    (set-env "GIT_SSH_COMMAND" "${pkgs.writeShellScript "git-ssh-disabled" ''
      echo "git push over SSH is disabled in this sandbox" >&2
      exit 1
    ''}")
    (set-env "SSH_AUTH_SOCK" "")
    (set-env "GIT_ASKPASS" "")
  ];

  termOptions = with jail.combinators; [
    (set-env "TERM" "xterm-256color")
    (set-env "COLORTERM" "truecolor")
    (set-env "TERMINFO_DIRS" "${pkgs.ncurses}/share/terminfo")
  ];

  packageManagerOptions = with jail.combinators; [
    (set-env "UV_CACHE_DIR" ".uv-cache")
    # TODO: npm, pnpm, bun, cargo, ...
  ];

  # Expose host PostgreSQL unix socket
  postgresOptions = with jail.combinators; [
    (try-readwrite "/run/postgresql")
  ];

  makeJailedAgent = {
    name,
    agent,
    profile ? "specDev",
    extraPkgs ? [],
    extraOptions ? [],
    workspaceDeps ? [], # sibling repo paths to bind-mount (for editable deps)
    allowSelfAsSubagent ? false,
    maxSubagentDepth ? 1,
    blockGitPush ? profileDefaults.${profile}.blockGitPush,
    sandboxGitIdentity ? profileDefaults.${profile}.sandboxGitIdentity,
    exposePostgres ? profileDefaults.${profile}.exposePostgres,
    useOpEnv ? profileDefaults.${profile}.useOpEnv,
  }: let
    selfSubagentPkg = pkgs.writeShellScriptBin "jailed-${name}" ''
      depth="''${JAILED_AGENT_DEPTH:-0}"

      if [ "$depth" -ge "${toString maxSubagentDepth}" ]; then
        echo "jailed-${name}: maximum sub-agent depth (${toString maxSubagentDepth}) reached" >&2
        exit 1
      fi

      export JAILED_AGENT_DEPTH="$((depth + 1))"
      exec ${lib.getExe agent} "$@"
    '';
    workspaceBinds =
      map (
        dep:
          jail.combinators.unsafe-add-raw-args
          "--bind \"${dep}\" \"/workspace/$(basename \"${dep}\")\""
      )
      workspaceDeps;

    inner =
      jail "jailed-${name}" agent (
        baseJailOptions
        ++ workspaceBinds
        ++ profileOptions.${profile}
        ++ termOptions
        ++ packageManagerOptions
        ++ lib.optionals blockGitPush gitPushBlockOptions
        ++ lib.optionals sandboxGitIdentity gitIdentityOptions
        ++ lib.optionals exposePostgres postgresOptions
        ++ lib.optionals useOpEnv apiKeyPassThrough
        ++ [
          (jail.combinators.add-pkg-deps (
            commonPkgs
            ++ extraPkgs
            ++ [agent] # allow sub-agent invocation
            ++ lib.optionals allowSelfAsSubagent [selfSubagentPkg]
          ))
        ]
        ++ extraOptions
      );

    # Outer wrapper: resolve op:// refs on the host (uses the 1Password
    # desktop app + biometric unlock via the user's PATH `op'), inject
    # plaintext into the wrapper's env, then exec the bwrap'd agent.
    # `op' is taken from PATH so the setuid wrapper at
    # /run/wrappers/bin/op (on NixOS) is preferred over the raw store
    # binary, which can't reach the desktop integration socket.
    outer = pkgs.writeShellScriptBin "jailed-${name}" ''
      if ! command -v op >/dev/null 2>&1; then
        echo "jailed-${name}: \`op' (1Password CLI) not found on PATH; cannot resolve secrets." >&2
        echo "  Either install 1password-cli or build this agent with useOpEnv = false." >&2
        exit 127
      fi
      exec op run --no-masking --env-file=${apiKeyEnvFile} -- \
        ${inner}/bin/jailed-${name} "$@"
    '';
  in
    assert builtins.hasAttr profile profileOptions
    || throw "Unknown jailed agent profile: ${profile}";
    assert (!allowSelfAsSubagent)
    || maxSubagentDepth > 0
    || throw "maxSubagentDepth must be > 0 when allowSelfAsSubagent = true";
      if useOpEnv then outer else inner;

  makeJailedPi = args:
    makeJailedAgent ({
        name = "pi";
        agent = pi;
      }
      // args);

  makeJailedCrush = args:
    makeJailedAgent ({
        name = "crush";
        agent = crush;
      }
      // args);

  makeJailedOpencode = args:
    makeJailedAgent ({
        name = "opencode";
        agent = opencode;
      }
      // args);

  makeJailedClaude = args:
    makeJailedAgent ({
        name = "claude";
        agent = claude-code;
      }
      // args);

  makeJailedCodex = args:
    makeJailedAgent ({
        name = "codex";
        agent = codex;
      }
      // args);

  makeJailedGemini = args:
    makeJailedAgent ({
        name = "gemini";
        agent = gemini-cli;
      }
      // args);

  makeJailedZerostack = args:
    makeJailedAgent ({
        name = "zerostack";
        agent = zerostack;
      }
      // args);
in {
  inherit
    makeJailedAgent
    makeJailedPi
    makeJailedCrush
    makeJailedOpencode
    makeJailedClaude
    makeJailedCodex
    makeJailedGemini
    makeJailedZerostack
    ;
  inherit commonPkgs;
  inherit (jail) combinators;
}
