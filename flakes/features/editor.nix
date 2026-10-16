# Editor features, in projection order. Shape: README § Feature tree.
{lib, ...}: let
  available = import ./available.nix lib;
in [
  (import ./editor/emacs.nix)

  # Modules the record owns: options.nvimPackages is declared only when
  # neovim is selected.
  {
    name = "neovim";
    homeManager = _: {
      imports = [
        ./editor/neovim/nvim.nix
        ./editor/neovim/nvim-plugins.nix
      ];
    };
  }

  {
    name = "kakoune";
    homeManager = {pkgs, ...}: {
      home.packages = available pkgs (with pkgs; [
        kakoune
        kakoune-lsp
        kakoune-cr
      ]);
    };
  }

  {
    name = "misc";
    homeManager = {pkgs, ...}: {
      home.packages = with pkgs;
        [
          # lapce # gui editor
          wordgrinder
        ]
        ++ available pkgs [
          micro-with-wl-clipboard
        ];
    };
  }

  {
    name = "zed";
    platforms = lib.platforms.linux;
    homeManager = {pkgs, ...}: {
      home.packages = [pkgs.zed-editor];
    };
  }

  {
    name = "lem";
    platforms = lib.platforms.linux;
    homeManager = {pkgs, ...}: {
      home.packages = with pkgs; [
        lem-ncurses
      ];
    };
  }
]
