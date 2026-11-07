# The base cli (DEC-031): what any home needs to function. Everything else is
# a feature.
{pkgs, ...}: {
  home.packages = with pkgs; [
    ## shell-ux
    starship
    carapace
    fzf
    atuin
    zoxide
    skim # $ sk

    ## fileutils
    coreutils
    xz
    zstd
    gnutar
    cpio
    zip
    unzip

    ## find
    file
    findutils

    ## text
    gnused
    gawk

    ## net
    curl
    wget
    openssl

    ## display
    less
    fontconfig

    ## scm
    git

    ## security
    gnupg

    ## nix
    nix-output-monitor # $ nom: switch and build progress (SL-012)
  ];
}
