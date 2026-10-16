# Terminal features, in projection order. Shape: README § Feature tree.
{lib, ...}: [
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
    homeManager = {
      pkgs,
      lib,
      ...
    }: {
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
        ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
          nerd-font-patcher
        ];
    };
  }
]
