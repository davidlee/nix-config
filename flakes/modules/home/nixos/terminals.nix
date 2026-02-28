_: {
  flake.homeModules.terminals = {pkgs, ...}: {
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
