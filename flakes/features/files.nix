# Files features, in projection order. Shape: README § Feature tree.
{lib, ...}: let
  available = import ./available.nix lib;
in [
  {
    name = "manage";
    homeManager = {
      pkgs,
      lib,
      ...
    }: {
      home.packages = with pkgs;
        [
          ## file managers
          broot
          cfm
          felix-fm
          ictree
          nnn
          mc
          ranger
          xplr
          lf
          superfile

          ## ls is more
          eza
          lsd
          pls
          tre
          bat

          # trash
          trash-cli
        ]
        ++ available pkgs [
          # hiPrio: wins bin/trash over the portable trash-cli above.
          (lib.hiPrio trashy)
        ];
    };
  }

  {
    name = "disk";
    homeManager = {pkgs, ...}: {
      home.packages = with pkgs;
        [
          ## disk & file io
          ncdu
          gdu
          duf
          dust
          pydf
        ]
        ++ available pkgs [
          mmtui # mount manager
          udiskie
        ];
    };
  }

  {
    name = "archive";
    homeManager = {pkgs, ...}: {
      home.packages = with pkgs; [
        ## compression
        unar
        _7zz
        unrar
        p7zip
      ];
    };
  }

  {
    name = "search";
    homeManager = {pkgs, ...}: {
      home.packages = with pkgs;
        [
          bfs # faster than fd

          ## file find & search
          docfd
          #    television
          nix-search-tv
          nix-search-cli
          fd
          fzy
          ripgrep
          vgrep
          sad
          ast-grep
          ripgrep-all
        ]
        ++ available pkgs [
          #semgrep
          fsearch
        ];
    };
  }

  {
    name = "sync";
    homeManager = {pkgs, ...}: {
      home.packages = with pkgs;
        [
          ## download / backup
          syncthing
          # backblaze-b2
        ]
        ++ available pkgs [
          backintime
        ];
    };
  }
]
