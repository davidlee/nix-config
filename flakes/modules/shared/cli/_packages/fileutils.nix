{
  pkgs,
  lib,
  ...
}: {
  common = with pkgs; [
    coreutils

    ## file managers
    broot
    cfm
    felix-fm
    ictree
    nnn
    mc
    ranger
    xplr
    yazi
    lf
    superfile

    ## ls is more
    eza
    lsd
    pls
    tre
    bat
    bfs # faster than fd

    ## disk & file io
    ncdu
    gdu
    duf
    dust
    pydf

    ## compression
    xz
    unar
    _7zz
    unrar
    p7zip
    unzip
    gnutar
    cpio
    zip

    ## download / backup
    syncthing
    # backblaze-b2
    aria2

    # trash
    trash-cli
  ];
  linuxHome = with pkgs; [
    backintime
    # hiPrio: wins bin/trash over the portable trash-cli in `common`.
    (lib.hiPrio trashy)
  ];
}
