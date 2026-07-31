{pkgs, ...}: {
  common = with pkgs; [
    ## text readers, pagers
    nvimpager
    less
    most
    moor
    viddy
    ov

    ## graphing
    graphviz

    ## dev introspection
    tokei

    ## image / graphics / multimedia
    pastel
    chafa
    viu

    ## screen rec
    asciinema

    ## fonts
    fontconfig

    ## highlighting
    chroma
  ];
  linuxHome = with pkgs; [
    d2
    fltrdr
    mermaid-cli
    structurizr-cli
    ueberzugpp
    ghostscript
    latex2html
    resvg
    ffmpeg-full
    nerd-font-patcher
  ];
}
