# The base cli (DEC-031): what any home needs to function. Everything else is
# a feature.
{
  pkgs,
  lib,
  ...
}: {
  home.packages = with pkgs;
    [
      ## shell-ux
      starship
      carapace
      fzf
    ]
    # atuin 18.23.0 is not cached for aarch64-darwin (ISS-007).
    ++ lib.optional stdenv.hostPlatform.isLinux atuin
    ++ [
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
    ];
}
