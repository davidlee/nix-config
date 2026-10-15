# Outer profile for a desktop workstation. Sets defaults only (mkDefault), so a
# host that imports it can override any of them with a plain definition.
{lib, ...}: {
  feature.session.snooze.enable = lib.mkDefault true;
  feature.virt.docker.enable = lib.mkDefault true;
  feature.non-nix-packages.appimage.enable = lib.mkDefault true;
  feature.non-nix-packages.flatpak.enable = lib.mkDefault true;
}
