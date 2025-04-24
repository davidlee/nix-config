{pkgs, stable, ... }: {

  environment.systemPackages = with pkgs; [
    ## cli general
    atuin # shell history 
    mprocs # parellel command runner
    tray-tui # systray

    ## system monitors
    atop
    bottom
    btop
    glances
    htop
    gtop
    iotop

    # session manager
    zellij
    tmux
    screen
    
    ## system utils
    isd # systemd
    lazyjournal # logs & containers
    systemctl-tui

    ## containers
    distrobox-tui
    docui
    lazydocker
    gomanagedocker

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
    mmtui # mount manager
    
    ## file find & search
    docfd
    television

    ## git / SCM
    debase
    gh-dash
    gitu
    gitui
    lazygit
    lazyjj
    jjui
    
    ## text editors
    helix
    kakoune
    neovim
    sc-im # er, spreadsheet
    wordgrinder

    ## notes / knowledge base
    kb
    nb
    tpnote
    tui-journal

    ## text utils
    cicero-tui # unicode 
    gtt # translation
    play # playground fer sed, grep, awk, ...

    ## markdown
    frogmouth
    glow
    marked-man
    md-tui

    ## CSV
    csv-tui
    tidy-viewer
    
    ## JSON
    jqp # jq
    otree # text object tree viewer

    ## PDF
    tdf

    ## text readers, pagers
    fltrdr
    nvimpager
    less
    most
    moar
    viddy

    ## feeds, content / social
    russ # RSS
    tuir # reddit
    tut # mastodon
    tuisky # bluesky
    wiki-tui # wikipedia
    
    ## hex edit for infinite grenades
    hexpatch
    hextazy
    hexyl

    ## typing
    thokr 
    ngrrram

    ## crypto
    libcryptui

    ## task / time / calendar mgmt
    basilk
    calcure
    calcurse
    taskflow
    task-keeper
    tasktimer
    taskwarrior-tui
    vault-tasks
    vit

    ## habit trackers
    dijo
    harsh
    
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

    ## paint
    # textual-paint

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
    clock-rs
    tty-clock
    crates-tui

    # bluetooth
    bluetui
    bluetuith

    ## www
    w3m
    browsh
    lynx

  ];
}
