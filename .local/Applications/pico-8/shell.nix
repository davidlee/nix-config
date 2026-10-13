{pkgs ? import <nixpkgs> {}}: let
  fhs = pkgs.buildFHSEnv {
    name = "pico8";
    targetPkgs = pkgs: (with pkgs; [
      xorg.libX11
      xorg.libXext
      xorg.libXcursor
      xorg.libXinerama
      xorg.libXi
      xorg.libXrandr
      xorg.libXScrnSaver
      xorg.libXxf86vm
      xorg.libxcb
      xorg.libXrender
      xorg.libXfixes
      xorg.libXau
      xorg.libXdmcp
      alsa-lib
      xorg.libXrandr # for renderer
      libGL # for renderer
      alsa-lib # for audio
      udev # for gamepads
      wget
      SDL2
      glibc
    ]);
    runScript = "bash -c ./pico8";
  };
in
  pkgs.stdenv.mkDerivation {
    name = "pico8-shell";
    nativeBuildInputs = [fhs];
    shellHook = ''
      # exec pico8
    '';
  }
