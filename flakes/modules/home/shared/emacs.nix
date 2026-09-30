{
  pkgs,
  inputs,
  ...
}:
let
  # From flakes/emacs, not built against this host's pkgs: the same
  # derivation the ~/.emacs.d devshell runs.
  emacs = inputs.emacs.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  imports = [ ./shpool.nix ];

  home.packages = [
    emacs
  ]
  ++ (with pkgs; [
    emacsclient-commands
    dict # testing dictd
    vips
    mediainfo
    poppler-utils
    # gnumake
    (texliveBasic.withPackages (ps: with ps; [
      latexmk
      wrapfig
      ulem
      capt-of
      collection-fontsrecommended
    ]))
  ]);
  services = {
    emacs = {
      client.enable = true;
      enable = true;
      package = emacs;
    };
  };
}
