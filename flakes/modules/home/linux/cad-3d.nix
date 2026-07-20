{pkgs, ...}: {
  home.packages = with pkgs; [
    openscad # openscad-unstable
  ];
}
