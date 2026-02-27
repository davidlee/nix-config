_: {
  flake.homeModules.editors = {pkgs, ...}: {
    home.packages = with pkgs; [
      sublime-merge
      joplin
    ];
  };
}
