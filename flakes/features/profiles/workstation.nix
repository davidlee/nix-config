# Outer profile for a desktop workstation. Sets defaults only (mkDefault), so a
# host that imports it can override any of them with a plain definition.
{lib, ...}: {
  feature.session.snooze.enable = lib.mkDefault true;
  feature.virt.docker.enable = lib.mkDefault true;
  feature.virt.sandbox.enable = lib.mkDefault true;
  feature.non-nix-packages.appimage.enable = lib.mkDefault true;
  feature.non-nix-packages.flatpak.enable = lib.mkDefault true;
  feature.desktop.core.enable = lib.mkDefault true;
  feature.desktop.fonts.enable = lib.mkDefault true;
  feature.audio.pipewire.enable = lib.mkDefault true;
  feature.web.browsers.enable = lib.mkDefault true;
  feature.terminal.emulators.enable = lib.mkDefault true;
  feature.comms.chat.enable = lib.mkDefault true;
  feature.comms.mail.enable = lib.mkDefault true;
  feature.media.players.enable = lib.mkDefault true;
  # The whole profile is Linux-only, through desktop.core's platforms (DEC-030),
  # so a darwin host cannot import it and dictate never reaches one.
  feature.audio.dictate.enable = lib.mkDefault true;
}
