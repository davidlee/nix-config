_: {
  flake.nixosModules.lib = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      # dictionaries
      hunspellDicts.en_AU
      hunspellDicts.en_AU-large
      hunspellDicts.en_GB-large
      hunspellDicts.en_US
      hunspellDicts.en_US-large

      ### libs
      ffmpeg
      glfw
      glib
      libffi
      libiconv
      libyaml
      openssl
      openssl.dev
      pkg-config
      # raylib
      zlib
      pixman
      # SDL
      # SDL2
      # SDL2_mixer
    ];
  };
}
