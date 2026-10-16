# Dev features, in projection order. Shape: README § Feature tree.
{lib, ...}: let
  available = import ./available.nix lib;
in [
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
        ++ available pkgs [
          # hiPrio: superset of the base's `git`; wins bin/git on Linux.
          (lib.hiPrio gitFull)
          gitui
          sublime-merge
        ];
    };
  }

  {
    name = "build";
    homeManager = {pkgs, ...}: {
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
        ++ available pkgs [
          lldb
          lld
          llvm
          clangStdenv
          libclang
          binutils
        ];
    };
    nixos = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [
        glib
        libffi
        libiconv
        libyaml
        openssl
        openssl.dev
        pkg-config
        zlib
        icu
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
    nixos = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [
        cargo
        cargo-update
      ];
    };
  }

  {
    name = "runners";
    homeManager = {pkgs, ...}: {
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
        ++ available pkgs [
          watchman
        ];
    };
  }

  {
    name = "tools";
    homeManager = {pkgs, ...}: {
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
        ++ available pkgs [
          ccache

          ## load test / benchmark
          hyperfine
        ];
    };
    nixos = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [
        valgrind
        sysprof
      ];
      services.sysprof.enable = true;
    };
  }
]
