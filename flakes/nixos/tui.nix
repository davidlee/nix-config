{pkgs,... }: {

  environment.systemPackages = with pkgs; [

    ## audio
    ncpamixer

    ## *

    asak
    atop
    atuin
    basilk
    bottom
    broot
    btop
    btop
    calcure
    calcurse
    cfm
    chess-tui
    cicero-tui
    clock-rs
    cmus
    crates-tui
    csv-tui
    debase
    dijo
    distrobox-tui
    di-tui
    docfd
    docui
    felix-fm
    fltrdr
    frogmouth
    fum
    gh-dash
    gitu
    gitu
    gitui
    glances
    glow
    gobang
    gomanagedocker
    gtop
    gtt
    harlequin
    harsh
    helix
    helix
    hexpatch
    hextazy
    hexyl
    htop
    ictree
    invidtui
    isd
    jjui
    jqp
    kakoune
    nb
    kb
    lazydocker
    lazygit
    lazyjj
    lazyjournal
    lazysql
    lf
    libcryptui
    managarr
    marked-man
    md-tui
    mmtui
    mprocs
    ncdu
    neovim
    nethack
    ngrrram
    nnn
    nvimpager
    otree
    play
    rainfrog
    ranger
    rmpc
    russ
    rustmission
    sc-im
    steam-tui
    stig
    superfile
    systemctl-tui
    taskflow
    task-keeper
    tasktimer
    taskwarrior-tui
    tdf
    television
    termusic
    # textual-paint
    thokr
    tidy-viewer
    tpnote
    tray-tui
    tty-clock
    tui-journal
    tuir
    tuisky
    tut
    vault-tasks
    vim-language-server
    vi-mongo
    vit
    wiki-tui
    wordgrinder
    xplr
    yazi
    youtube-tui
    ytermusic

    ## www
    w3m
    browsh
    lynx

  ];
}
