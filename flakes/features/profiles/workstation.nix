# Outer profile for a desktop workstation. Sets defaults only (mkDefault), so a
# host that imports it can override any of them with a plain definition.
{lib, ...}: {
  feature.session.snooze.enable = lib.mkDefault true;
  feature.virt.docker.enable = lib.mkDefault true;
  feature.non-nix-packages.appimage.enable = lib.mkDefault true;
  feature.non-nix-packages.flatpak.enable = lib.mkDefault true;
  feature.desktop.core.enable = lib.mkDefault true;
  feature.desktop.fonts.enable = lib.mkDefault true;
  feature.audio.pipewire.enable = lib.mkDefault true;
  # Linux-only home half: a darwin host importing this profile would select it
  # and fail ADR-005 D6 / hit QUE-001.
  feature.audio.dictate.enable = lib.mkDefault true;
}
