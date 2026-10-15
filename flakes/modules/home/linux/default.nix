{config, ...}: {
  imports = [
    ./ai.nix
    ./alarm.nix
    ./browsers.nix
    ./editors.nix
    ./graphics.nix
    # ./helix.nix
    ./media.nix
    ./obs-studio.nix
    ./office.nix
    ./terminals.nix
    ./wayland.nix
    ./zed-editor.nix

    # parked — its flake input is commented out in ../../../flake.nix
    # ./danksearch.nix
  ];

  # GUI apps launched by the compositor never source a shell profile
  systemd.user.sessionVariables = config.home.sessionVariables;
}
