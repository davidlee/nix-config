# Centralised jailed LLM agent definitions.
#
# Each agent (pi, crush, opencode, claude, codex, gemini) can run under any sandbox profile.
# Profiles control persistence, networking, and policy defaults;
# agent wrappers remain thin.
#
# Usage:
#   makeJailedPi { profile = "specDev"; extraPkgs = [ go ]; }
#   makeJailedAgent { name = "foo"; agent = foo-pkg; profile = "research"; }
{
  pkgs,
  jail-nix,
  llm-agents,
}: let
  lib = pkgs.lib;
  system = pkgs.stdenv.system;
  jail = jail-nix.lib.init pkgs;

  pi = llm-agents.packages.${system}.pi;
  crush = llm-agents.packages.${system}.crush;
  opencode = llm-agents.packages.${system}.opencode;
  claude-code = llm-agents.packages.${system}.claude-code;
  codex = llm-agents.packages.${system}.codex;
  gemini-cli = llm-agents.packages.${system}.gemini-cli;

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

  # Per-profile boolean defaults for git controls
  profileDefaults = {
    specDev = {
      blockGitPush = true;
      sandboxGitIdentity = true;
      exposePostgres = false;
    };

    research = {
      blockGitPush = true;
      sandboxGitIdentity = false;
      exposePostgres = false;
    };

    offline = {
      blockGitPush = true;
      sandboxGitIdentity = false;
      exposePostgres = false;
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
    blockGitPush ? (profileDefaults.${profile}).blockGitPush,
    sandboxGitIdentity ? (profileDefaults.${profile}).sandboxGitIdentity,
    exposePostgres ? (profileDefaults.${profile}).exposePostgres,
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
    workspaceBinds = map (dep:
      jail.combinators.unsafe-add-raw-args
        "--bind \"${dep}\" \"/workspace/$(basename \"${dep}\")\""
    ) workspaceDeps;
  in
    assert builtins.hasAttr profile profileOptions
    || throw "Unknown jailed agent profile: ${profile}";
    assert (!allowSelfAsSubagent)
    || maxSubagentDepth > 0
    || throw "maxSubagentDepth must be > 0 when allowSelfAsSubagent = true";
      jail "jailed-${name}" agent (
        baseJailOptions
        ++ workspaceBinds
        ++ profileOptions.${profile}
        ++ termOptions
        ++ packageManagerOptions
        ++ lib.optionals blockGitPush gitPushBlockOptions
        ++ lib.optionals sandboxGitIdentity gitIdentityOptions
        ++ lib.optionals exposePostgres postgresOptions
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
in {
  inherit makeJailedAgent makeJailedPi makeJailedCrush makeJailedOpencode
    makeJailedClaude makeJailedCodex makeJailedGemini;
  inherit commonPkgs;
  combinators = jail.combinators;
}
