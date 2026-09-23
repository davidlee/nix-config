{pkgs, ...}: let
  emacs = import ../../../emacs/emacs.nix {inherit pkgs;};
in {
  imports = [./shpool.nix];

  home.packages =
    [
      emacs
    ]
    ++ (with pkgs; [
      emacsclient-commands
      dict # testing dictd
      vips
      mediainfo
      poppler-utils
      # gnumake
      (texlive.combine {
        inherit
          (texlive)
          scheme-basic
          latexmk
          wrapfig
          ulem
          capt-of
          collection-fontsrecommended
          ;
      })
    ]);

  services = {
    emacs = {
      client.enable = true;
      enable = true;
      package = emacs;
      defaultEditor = true;
    };
  };
}
