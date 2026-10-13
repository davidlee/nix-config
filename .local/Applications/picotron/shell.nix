{pkgs ? import <nixpkgs> {}}: let
  fhs = pkgs.buildFHSEnv {
    name = "picotron";
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
      udev
      libGL
      mesa.drivers
      vulkan-loader
      SDL2
      xorg.libXtst
      wget
      curl
    ]);
    runScript = "bash -c 'SDL_VIDEODRIVER=x11 ./picotron'";
  };
in
  pkgs.stdenv.mkDerivation {
    name = "picotron-shell";
    nativeBuildInputs = [fhs];
    shellHook = ''
      exec picotron
    '';
  }
