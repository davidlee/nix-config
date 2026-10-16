# Files features, in projection order. Shape: README § Feature tree.
_: [
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
          yazi
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
        ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
          # hiPrio: wins bin/trash over the portable trash-cli above.
          (lib.hiPrio trashy)
        ];
    };
  }

  {
    name = "disk";
    homeManager = {
      pkgs,
      lib,
      ...
    }: {
      home.packages = with pkgs;
        [
          ## disk & file io
          ncdu
          gdu
          duf
          dust
          pydf
        ]
        ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
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
    homeManager = {
      pkgs,
      lib,
      ...
    }: {
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
          mcfly
          ripgrep
          vgrep
          sad
          ast-grep
          ripgrep-all
        ]
        ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
          #semgrep
          fsearch
        ];
    };
  }

  {
    name = "sync";
    homeManager = {
      pkgs,
      lib,
      ...
    }: {
      home.packages = with pkgs;
        [
          ## download / backup
          syncthing
          # backblaze-b2
        ]
        ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
          backintime
        ];
    };
  }
]
