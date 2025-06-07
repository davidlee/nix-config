{pkgs, stable, inputs, ... }: {

  imports = [
    ../modules/shared-tui.nix  
  ];

  environment.systemPackages = with pkgs; [
    inputs.helix.packages.x86_64-linux.default
    
    ## cli general
    mprocs # parellel command runner
    tray-tui # systray
    
    ## system utils
    isd # systemd
    lazyjournal # logs & containers
    systemctl-tui

    ## system monitors
    atop
    iotop

    ## text utils
    cicero-tui # unicode 
    gtt

    ## text readers, pagers
    fltrdr

    ## containers
    distrobox-tui
    docui
    lazydocker
    gomanagedocker

    ## disk & file io 
    mmtui # mount manager
    
    ## PDF
    tdf

    ## crypto
    libcryptui

    ## database
    gobang
    lazysql
    rainfrog
    stable.harlequin
    vi-mongo

    ## audio / music
    ncpamixer
    asak
    cmus
    di-tui # di.fm player
    fum
    termusic
    rmpc

    ## games
    chess-tui
    nethack
    steam-tui
    
    ## arr
    managarr
    stig
    rustmission
    
    ## youtube
    invidtui
    youtube-tui
    ytermusic
    
    ## clock
    tty-clock

    # rust
    crates-tui

    # bluetooth
    bluetui
    bluetuith

  ];
}
