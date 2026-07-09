{pkgs, ...}: {
  common = with pkgs; [
    zsh
    zstd
    zsh-autocomplete
    antidote
    shellcheck
    shfmt
  ];
}
