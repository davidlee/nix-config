# The shared Wayland stack every compositor session here uses (DEC-026).
# Never toggled in parts; compositors require it.
{
  name = "core";
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
}
