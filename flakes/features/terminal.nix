# Terminal features, in projection order. Shape: README § Feature tree.
{lib, ...}: let
  available = import ./available.nix lib;
in [
  {
    name = "emulators";
    platforms = lib.platforms.linux;
    homeManager = {
      lib,
      pkgs,
      ...
    }: {
      # A running ghostty stops seeing other apps' clipboard after a switch,
      # pasting its own last copy; a new process, or a config reload, is fine.
      # Cause unknown. SIGUSR2 is ghostty's reload signal.
      home.activation.reloadGhostty = lib.hm.dag.entryAfter ["linkGeneration"] ''
        run ${pkgs.procps}/bin/pkill -USR2 -x .ghostty-wrappe || true
      '';
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

  # A shell's record owns the user's login shell (`users.users.<user>.shell`),
  # beside the system setup it needs. To change the login shell, move the
  # `shell =` line from one record to the other and select that feature.
  # Without one, the user gets NixOS's bash (modules/nixos/user.nix).

  {
    # zsh: the home half (dotfiles, mcfly, plugins) and the system half
    # (programs.zsh, /share/zsh completions, the login shell). Its login hook
    # execs nu. Root's shell is bash (DEC-042).
    name = "zsh";
    homeManager = {pkgs, ...}: {
      imports = [./terminal/zsh.nix];
      home.packages = with pkgs; [
        zsh
        antidote
      ];
    };
    nixos = {
      pkgs,
      username,
      ...
    }: {
      programs.zsh.enable = true; # NixOS refuses a zsh login shell without it
      users.users.${username}.shell = pkgs.zsh;
      environment.pathsToLink = ["/share/zsh"]; # completions from packages
    };
  }

  {
    # nushell, and fish for its completions. Home only: to make nu the login
    # shell, add a nixos half here holding the `shell =` line from zsh's.
    name = "nushell";
    requires = ["terminal.amenities"]; # its cd alias is zoxide's
    homeManager = {imports = [./terminal/nushell.nix];};
  }

  {
    # Interactive tools shared by the shells (completion, history, jump, fuzzy
    # find); each hooks into whichever shell records are selected.
    name = "amenities";
    homeManager = {imports = [./terminal/amenities.nix];};
  }

  {
    # The prompt, in every selected shell; theme beside it, derived from
    # oh-my-posh's M365Princess. Preview an edit without a switch:
    #   oh-my-posh print primary --config features/terminal/oh-my-posh.json
    name = "oh-my-posh";
    homeManager = {
      programs.oh-my-posh = {
        enable = true;
        configFile = ./terminal/oh-my-posh.json;
      };
    };
  }
]
