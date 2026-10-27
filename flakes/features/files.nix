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

      # From the home base (DEC-042).
      programs.yazi = {
        enable = true;
        plugins = with pkgs.yaziPlugins; {
          lazygit.package = lazygit;
          jjui.package = jjui;
          glow.package = glow;
          wl-clipboard.package = wl-clipboard;
          # Plugins that don't call setup() can be configured in one line
          smart-enter.package = smart-enter;
          chmod.package = chmod;

          # Yatline-Catppuccin needs to be setup into a variable later
          yatline-catppuccin.package = yatline-catppuccin;

          yatline = {
            package = yatline;
            setup = true;
            settings = {
              tab_width = 20;
              # Return as lua code
              theme = lib.mkLuaInline ''
                require("yatline-catppuccin"):setup("mocha")
              '';
            };
          };
        };
        shellWrapperName = "y";
      };
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
    # udiskie's backend
    nixos = _: {
      services.udisks2.enable = true;
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

      # Its package is listed above (DEC-042).
      programs.nix-search-tv.enableTelevisionIntegration = true;
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

  {
    name = "locate";
    nixos = {pkgs, ...}: {
      services.locate = {
        enable = true;
        package = pkgs.plocate;
        interval = "hourly";
        prunePaths = [
          "/tmp"
          "/var/tmp"
          "/var/cache"
          "/var/lock"
          "/var/run"
          "/var/spool"
          "/nix/store"
          "/nix/var/log/nix"
        ];
      };
    };
  }
]
