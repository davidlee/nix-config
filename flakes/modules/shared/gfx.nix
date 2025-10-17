{...}: let
  gfxPackages = pkgs:
    with pkgs; [
      ## graphing
      d2
      graphviz
      mermaid-cli
      structurizr-cli

      ## image / graphics / multimedia
      ffmpeg
      glfw
      pastel
      chafa
      ueberzugpp
      viu
      ghostscript
      latex2html

      ## fonts
      nerd-font-patcher
      fontconfig
    ];
in {
  flake.nixosModules.gfx = {pkgs, ...}: {
    environment.systemPackages = gfxPackages pkgs;
  };

  flake.darwinModules.gfx = {pkgs, ...}: {
    environment.systemPackages = gfxPackages pkgs;
  };
}
