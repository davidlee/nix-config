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
]
