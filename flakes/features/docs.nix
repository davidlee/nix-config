# Docs features, in projection order. Shape: README § Feature tree.
{lib, ...}: let
  available = import ./available.nix lib;
in [
  {
    name = "diagrams";
    homeManager = {pkgs, ...}: {
      home.packages = with pkgs;
        [
          graphviz
        ]
        ++ available pkgs [
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
    homeManager = {pkgs, ...}: {
      home.packages = with pkgs;
        [
          typst
        ]
        ++ available pkgs [
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
        leaf-markdown-viewer
        # marked-man
        # md-tui
      ];
    };
  }

  {
    name = "help";
    homeManager = {pkgs, ...}: {
      home.packages = available pkgs (with pkgs; [
        # tealdeer is the tldr client (provides bin/tldr); plain `tldr` dropped.
        tealdeer
        cheat
        pinfo
      ]);
    };
  }
]
