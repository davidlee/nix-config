{
  pkgs,
  inputs,
  ...
}: let
  # From flakes/emacs, not built against this host's pkgs: the same
  # derivation the ~/.emacs.d devshell runs.
  emacs = inputs.emacs.packages.${pkgs.stdenv.hostPlatform.system}.default;
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
