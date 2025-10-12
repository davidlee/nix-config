{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    ## graphing
    d2
    graphviz
    mermaid-cli
    structurizr-cli

    ## image / graphics / multimedia
    ffmpeg
    glfw
    pastel
    chafa
    ueberzugpp
    viu
    ghostscript
    latex2html

    ## fonts
    nerd-font-patcher
    fontconfig
  ];
}
