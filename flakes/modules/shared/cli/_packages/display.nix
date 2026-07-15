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
    mermaid-cli
    structurizr-cli

    ## dev introspection
    tokei

    ## image / graphics / multimedia
    pastel
    chafa
    ueberzugpp
    viu
    ghostscript
    latex2html
    resvg
    ffmpeg-full

    ## fonts
    nerd-font-patcher
    fontconfig

    ## highlighting
    chroma
  ];
  linuxHome = with pkgs; [
    d2
    fltrdr
  ];
}
