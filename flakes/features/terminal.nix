# Terminal features, in projection order. Shape: README § Feature tree.
{lib, ...}: let
  available = import ./available.nix lib;
in [
  {
    name = "emulators";
    platforms = lib.platforms.linux;
    homeManager = {pkgs, ...}: {
      home.packages = with pkgs; [
        # alacritty
        # wezterm
        foot
        ghostty
        kitty
        # rio
        # warp-terminal
      ];
    };
  }

  {
    name = "utils";
    homeManager = {pkgs, ...}: {
      home.packages = with pkgs;
        [
          ## screen rec
          asciinema

          tmux
          zmx # or this

          # abduco # shell persist
          # dvtm # + abduco (suckless)
          # shpool # vs abduco . has a service too
          # sesh  # temporarily broken transitive dep: (go-mockery)

          ## clock
          clock-rs
        ]
        ++ available pkgs [
          nerd-font-patcher
        ];
    };
  }

  {
    # zsh: the home half (dotfiles, mcfly, plugins) and the system half
    # (programs.zsh, /share/zsh completions). Root's shell is bash (DEC-042).
    name = "zsh";
    homeManager = {pkgs, ...}: {
      imports = [./terminal/zsh.nix];
      home.packages = with pkgs; [
        zsh
        antidote
      ];
    };
    nixos = _: {
      programs.zsh.enable = true;
      environment.pathsToLink = ["/share/zsh"]; # completions from packages
    };
  }
]
