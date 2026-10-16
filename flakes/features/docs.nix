# Docs features, in projection order. Shape: README § Feature tree.
_: [
  {
    name = "diagrams";
    homeManager = {
      pkgs,
      lib,
      ...
    }: {
      home.packages = with pkgs;
        [
          graphviz
        ]
        ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
          d2
          mermaid-cli
          structurizr-cli
          yed
          drawio
        ];
    };
  }

  {
    name = "typeset";
    homeManager = {
      pkgs,
      lib,
      ...
    }: {
      home.packages = with pkgs;
        [
          typst
        ]
        ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
          ghostscript
          latex2html

          ## pdf
          tdf

          # convert
          pandoc
        ];
    };
  }

  {
    name = "markdown";
    homeManager = {pkgs, ...}: {
      home.packages = with pkgs; [
        # markdownlint-cli
        # markdownlint-cli2
        markdown-oxide
        marksman # serena wants it
        # frogmouth
        glow
        rich-cli
        # marked-man
        # md-tui
      ];
    };
  }

  {
    name = "help";
    homeManager = {
      pkgs,
      lib,
      ...
    }: {
      home.packages = lib.optionals pkgs.stdenv.hostPlatform.isLinux (with pkgs; [
        # tealdeer is the tldr client (provides bin/tldr); plain `tldr` dropped.
        tealdeer
        cheat
        pinfo
      ]);
    };
  }
]
