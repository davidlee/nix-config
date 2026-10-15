# IMP-004: Move WM-specific packages out of wayland_packages.nix

Most of `modules/nixos/wayland_packages.nix` is used under every compositor (swaybg, grimshot, …) and stays shared. A few belong to one window manager (e.g. hyprpicker) and should move to it during the desktop-area migration.
