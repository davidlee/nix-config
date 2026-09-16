{
  lib,
  features,
  ...
}: {
  imports =
    [
      ./ai.nix
      ./alarm.nix
      ./browsers.nix
      ./editors.nix
      ./graphics.nix
      ./helix.nix
      ./media.nix
      ./obs-studio.nix
      ./office.nix
      ./terminals.nix
      ./wayland.nix
      ./zed-editor.nix

      # parked — its flake input is commented out in ../../../flake.nix
      # ./danksearch.nix
    ]
    ++ lib.optional features.apps.cad ./cad-3d.nix
    ++ lib.optional features.desktop.niri ./niri.nix
    ++ lib.optional features.desktop.sway ./sway.nix
    ++ lib.optional features.games.mangohud ./games.nix
    ++ lib.optional features.snooze ./snooze.nix;
}
