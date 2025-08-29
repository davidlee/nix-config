{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    ## LLM / AI
    ollama
    mods
    mistral-rs
    # oterm # BROKEN
    # aichat
    # aider-chat-full
    # llama-cpp
    # vllm
    # llm
    # llm-ls

    ## cli history
    atuin

    ## system monitors
    bottom
    btop
    glances
    htop
    gtop

    # session manager
    zellij
    tmux
    # screen

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

    ## file find & search
    docfd
    television

    ## git / SCM
    debase
    gh-dash
    # gitu
    # gitui # BROKEN
    lazygit
    lazyjj
    jjui

    ## text editors
    # helix REPLACED w edge
    kakoune
    kakoune-lsp
    kakoune-cr
    neovim
    sc-im # er, spreadsheet
    wordgrinder

    ## notes / knowledge base
    kb
    nb
    tpnote
    tui-journal

    ## text utils
    play # playground for sed, grep, awk, ...

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

    ## text readers, pagers
    # fltrdr
    nvimpager
    less
    most
    moar
    viddy
    ov

    ## feeds, content / social
    russ # RSS
    tuir # reddit
    tut # mastodon
    tuisky # bluesky
    wiki-tui # wikipedia
    slack-term

    ## hex edit for infinite grenades
    hexpatch
    hextazy
    hexyl

    ## typing
    thokr
    ngrrram

    ## task / time / calendar mgmt
    basilk
    # calcure
    calcurse
    # gcalcli
    taskflow
    task-keeper
    tasktimer
    taskwarrior-tui
    vault-tasks
    vit

    ## habit trackers
    dijo
    harsh

    ## clock
    clock-rs
    # tty-clock

    # rust
    crates-tui

    ## www
    w3m-full
    browsh
    lynx
  ];
}
