# Editor features, in projection order. Shape: README § Feature tree.
{lib, ...}: [
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
    homeManager = {
      pkgs,
      lib,
      ...
    }: {
      home.packages = lib.optionals pkgs.stdenv.hostPlatform.isLinux (with pkgs; [
        kakoune
        kakoune-lsp
        kakoune-cr
      ]);
    };
  }

  {
    name = "misc";
    homeManager = {
      pkgs,
      lib,
      ...
    }: {
      home.packages = with pkgs;
        [
          # lapce # gui editor
          wordgrinder
        ]
        ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
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
