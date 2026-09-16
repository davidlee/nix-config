{username, ...}: {
  systemd.services.mpd.environment = {
    # https://gitlab.freedesktop.org/pipewire/pipewire/-/issues/609
    XDG_RUNTIME_DIR = "/run/user/${toString 1000}"; # User-id must match above user. MPD will look inside this directory for the PipeWire socket.
  };
  services = {
    mpd = {
      user = username;
      enable = true;
      musicDirectory = "/media/music";
      # `extraConfig` was removed upstream in favour of RFC42-style settings.
      settings = {
        audio_output = [
          {
            type = "pipewire";
            name = "My PipeWire Output";
          }
        ];
      };
    };
  };
}
