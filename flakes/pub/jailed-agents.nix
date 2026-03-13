# Centralised jailed LLM agent definitions.
#
# Usage from a project flake:
#   jailed-agents.lib.${system}.makeJailedAgent {
#     name = "crush";
#     agent = crush-pkg;
#     extraPkgs = [ go gopls ];
#   }
#
# Or use the pre-built makers:
#   jailed-agents.lib.${system}.makeJailedCrush { extraPkgs = [...]; }

{ pkgs, jail-nix, llm-agents }:

let
  lib = pkgs.lib;
  system = pkgs.stdenv.system;
  jail = jail-nix.lib.init pkgs;

  pi = llm-agents.packages.${system}.pi;
  crush = llm-agents.packages.${system}.crush;
  opencode = llm-agents.packages.${system}.opencode;

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
    less
    ov
    glow
    helix
    ps
    ncurses
  ];

  commonJailOptions = with jail.combinators; [
    (persist-home "agent")
    network
    time-zone
    no-new-session
    # Mount host cwd at /workspace/<project> and start there
    (unsafe-add-raw-args "--bind \"$PWD\" \"/workspace/$(basename \"$PWD\")\"")
    (unsafe-add-raw-args "--chdir \"/workspace/$(basename \"$PWD\")\"")
  ];

  # Sandbox-originated commits are visually distinct
  gitIdentityOptions = with jail.combinators; [
    (set-env "GIT_AUTHOR_NAME" "pi-mono")
    (set-env "GIT_AUTHOR_EMAIL" "pi-mono@local")
    (set-env "GIT_COMMITTER_NAME" "pi-mono")
    (set-env "GIT_COMMITTER_EMAIL" "pi-mono@local")
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
    (set-env "TERMINFO_DIRS" "${pkgs.ncurses}/share/terminfo")
  ];

  makeJailedAgent = {
    name,
    agent,
    extraPkgs ? [],
    extraOptions ? [],
    blockGitPush ? true,
    sandboxGitIdentity ? true,
  }:
    jail "jailed-${name}" agent (with jail.combinators;
      commonJailOptions
      ++ termOptions
      ++ lib.optionals blockGitPush gitPushBlockOptions
      ++ lib.optionals sandboxGitIdentity gitIdentityOptions
      ++ [
        (add-pkg-deps (commonPkgs ++ extraPkgs))
      ]
      ++ extraOptions
    );

  makeJailedPi = args: makeJailedAgent ({ name = "pi"; agent = pi; } // args);
  makeJailedCrush = args: makeJailedAgent ({ name = "crush"; agent = crush; } // args);
  makeJailedOpencode = args: makeJailedAgent ({ name = "opencode"; agent = opencode; } // args);

in {
  inherit makeJailedAgent makeJailedPi makeJailedCrush makeJailedOpencode;
  inherit commonPkgs;
}
