{pkgs, ...}: {
  home.packages = with pkgs; [
    # obsidian
    sublime-merge
    joplin
  ];
}
