{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    ## file managers
    broot
    cfm
    felix-fm
    ictree
    nnn
    ranger
    xplr
    yazi
    lf
    superfile

    ## disk & file io
    ncdu
    gdu
    duf
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

    ## download / backup
    syncthing
    backblaze-b2
    aria2
    # backintime
  ];
}
