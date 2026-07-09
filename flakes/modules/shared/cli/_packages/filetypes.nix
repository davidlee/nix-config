{pkgs, ...}: {
  common = with pkgs; [
    ## markdown
    # markdownlint-cli
    # markdownlint-cli2
    markdown-oxide
    marksman # serena wants it
    # frogmouth
    glow
    gum
    rich-cli
    # marked-man
    # md-tui

    ### google cal
    gcalcli

    typst

    ## CSV
    # tidy-viewer

    ## JSON / YAML
    otree # text object tree viewer
    gron
    jq
    xq
    jqp # jq tui playground
    yq-go # jq for yaml
    jc
    jless

    ## regex
    grex
  ];
  linuxHome = with pkgs; [
    ## csv
    csv-tui

    ## pdf
    tdf

    ### unicode
    cicero-tui # unicode

    ## translate
    gtt

    ## text readers
    circumflex

    ## hex editors
    hexyl
    unixtools.xxd

    # convert
    pandoc
  ];
}
