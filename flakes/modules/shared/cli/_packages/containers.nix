{pkgs, ...}: {
  ## sandbox/container substrate, Linux-only
  linuxSystem = with pkgs; [
    bubblewrap
    distrobox
    distrobox-tui
    #devcontainer
  ];
}
