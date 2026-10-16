# The shared Wayland stack every compositor session here uses (DEC-026), both
# halves: the system stack, and the session's home pieces (cursor, tray,
# wallpaper, notifications). Never toggled in parts; compositors require it.
# Linux-only.
{lib, ...}: {
  name = "core";
  platforms = lib.platforms.linux;
  nixos = _: {
    imports = [
      ./core/wayland.nix
      ./core/wayland_packages.nix
      ./core/x11.nix
      ./core/xdg.nix
      ./core/qt.nix
      ./core/keyring.nix # + greetd keyring PAM from security.nix; minus polkit
      ./core/gui.nix # GUI programs and libraries, session glue
      ./core/v4l2loopback.nix # from kernel.nix
    ];
  };
  homeManager = _: {
    imports = [./core/home.nix];
  };
}
