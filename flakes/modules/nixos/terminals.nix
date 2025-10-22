_: {
  flake.nixosModules.terminals = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      ## terminals
      alacritty
      #wezterm
      foot
      ghostty
      kitty
      rio
      warp-terminal
    ];
  };
}
