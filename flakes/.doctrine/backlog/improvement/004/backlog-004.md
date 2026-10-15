# IMP-004: Move WM-specific packages out of wayland_packages.nix

Most of `modules/nixos/wayland_packages.nix` is used under every compositor (swaybg, grimshot, …) and stays shared. A few belong to one window manager (e.g. hyprpicker) and should move to it during the desktop-area migration.

SL-006 (design, 2026-10-16; RV-013 F-5): `waybar` leaves `wayland_packages.nix`
for `desktop.sway`, whose home half starts it. `cava`, `grimshot` (also the zsh
`scr` alias), `hyprpicker`, `swaybg`, `swayimg` and `kanshi` are
compositor-agnostic and stay shared. Remaining: prune entries nothing uses —
`wob`, `i3status`, `wf-config` (wayfire), `gnomeExtensions.appindicator` and
`marble-shell-theme` (GNOME Shell). A removal, so a behaviour change: not
set-preserving.

SL-006 PHASE-04: fold-in done — `waybar` left `wayland_packages.nix`
(`desktop.sway` lists it); `cava`'s duplicate left the sway record. Remaining:
the prune above.
