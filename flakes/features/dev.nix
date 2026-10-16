# Dev features, in projection order. Shape: README § Feature tree.
_: [
  {
    name = "scm";
    homeManager = {
      pkgs,
      lib,
      ...
    }: {
      home.packages = with pkgs;
        [
          git-revise
          delta
          diffedit3
          diffnav
          diffr
          diffstat
          difftastic
          gh
          hub
          jujutsu
          mergiraf
          tig
          debase # broken
          gh-dash
          lazygit
          lazyjj
          jjui
        ]
        ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
          # hiPrio: superset of the base's `git`; wins bin/git on Linux.
          (lib.hiPrio gitFull)
          gitui
          sublime-merge
        ];
    };
  }

  {
    name = "build";
    homeManager = {
      pkgs,
      lib,
      ...
    }: {
      home.packages = with pkgs;
        [
          ## build tools
          gnumake
          ninja
          autoconf
          cmake
          # redo-apenwarr

          ## parse / lex
          bison

          ## lang.c
          gcc
        ]
        ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
          lldb
          lld
          llvm
          clangStdenv
          libclang
          binutils
        ];
    };
  }

  {
    name = "runtimes";
    homeManager = {pkgs, ...}: {
      home.packages = with pkgs; [
        nodejs_latest # npx
        uv
        python3
        mise
      ];
    };
  }

  {
    name = "runners";
    homeManager = {
      pkgs,
      lib,
      ...
    }: {
      home.packages = with pkgs;
        [
          just

          ## supervisors / runners
          overmind
          watch
          watcher
          watchexec
          fswatch
          viddy
          entr
        ]
        ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
          # watchman pulls the folly/fbthrift C++ tower, which currently
          # fails to build on aarch64-darwin; keep it Linux-only.
          watchman
        ];
    };
  }

  {
    name = "tools";
    homeManager = {
      pkgs,
      lib,
      ...
    }: {
      home.packages = with pkgs;
        [
          exercism
          claude-monitor

          ## assorted qol
          moreutils

          ## dev introspection
          tokei

          gum

          ## shell scripts
          shellcheck
          shfmt
        ]
        ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
          ccache

          ## load test / benchmark
          hyperfine
        ];
    };
  }
]
