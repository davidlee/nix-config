_: {
  flake.homeModules.emacs = {
    pkgs,
    self,
    inputs,
    ...
  }: let
    emacs = import ../../pub/emacs.nix {
      inherit pkgs;
      emacsConfig = inputs.emacs-config;
    };
  in {
    imports = [self.homeModules.shpool];

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

    # DISABLED while I'm still rebooting all the time
    # services = {
    #   emacs = {
    #     client.enable = true;
    #     enable = false;
    #     package = emacs;
    #   };
    # };
  };
}
