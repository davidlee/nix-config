{pkgs, ...}: {
  home.packages = with pkgs; [
    # diagrams
    yed
    drawio
  ];
}
