# editor.emacs: Emacs from flakes/emacs (on PATH and as the services.emacs
# daemon) and EDITOR/VISUAL. Its own file: README § Emacs. Listed in
# ../editor.nix.
{
  name = "emacs";
  homeManager = {
    pkgs,
    lib,
    inputs,
    ...
  }: let
    # From flakes/emacs, not built against this host's pkgs: the same
    # derivation the ~/.config/emacs devshell runs.
    emacs = inputs.emacs.packages.${pkgs.stdenv.hostPlatform.system}.default;
    available = import ../available.nix lib;
  in {
    home.packages =
      [
        emacs
      ]
      ++ (with pkgs; [
        emacsclient-commands
        zmx # session restore (IMP-001)
        vips
        mediainfo
        poppler-utils
        # gnumake
        (texliveBasic.withPackages (ps:
          with ps; [
            latexmk
            wrapfig
            ulem
            capt-of
            collection-fontsrecommended
          ]))
      ])
      ++ available pkgs [pkgs.emacs-all-the-icons-fonts];

    home.sessionVariables = {
      EDITOR = "emacsclient -c";
      VISUAL = "emacsclient -c";
    };

    services = {
      emacs = {
        client.enable = true;
        enable = true;
        package = emacs;
      };
    };
  };
}
