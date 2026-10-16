{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    ### libs
    glib
    libffi
    libiconv
    libyaml
    openssl
    openssl.dev
    pkg-config
    # raylib
    zlib
    icu
    # SDL
    # SDL2
    # SDL2_mixer
  ];
}
