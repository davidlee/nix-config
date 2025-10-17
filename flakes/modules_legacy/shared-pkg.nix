{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    unixtools.net-tools
    unixtools.xxd
    flatpak
    devcontainer
  ];
}
# ## package management comma
# cachix
# devcontainer
# devenv
# manix
# alejandra
# nh
# nil
# nix-bisect
# nix-btm
# nixd
# nix-diff
# # nix-direnv
# nix-du
# nix-index
# nix-inspect
# nix-melt
# nix-output-monitor
# nix-bash-completions
# nix-search-cli
# nix-search-tv
# nix-derivation
# nix-deploy
# nix-forecast
# nix-health
# # nix-janitor
# nix-top
# nix-tree
# nixfmt-rfc-style
# nvd
# pkg-config
# unixtools.net-tools
# unixtools.xxd

