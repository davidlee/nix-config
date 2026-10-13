{
  pkgs,
  inputs,
  ...
}: let
  # From flakes/emacs, not built against this host's pkgs: the same
  # derivation the ~/.config/emacs devshell runs.
  emacs = inputs.emacs.packages.${pkgs.stdenv.hostPlatform.system}.default;

  # Webster's Revised Unabridged Dictionary (1913), StarDict format, read by
  # sdcv (quick-sdcv in Emacs). Public domain.
  web1913 = pkgs.fetchzip {
    url = "https://raw.githubusercontent.com/ahacop/websters-dict-1913-stardict/7f9c6d6725eb1b0d8545a6f74904610fa2a2c71e/stardict-dictd-web1913-2.4.2.tgz";
    hash = "sha256-wEnu6azvGJt8bxWd/lZGuiFwEP+l+gpxD1e+7CI7tz0=";
  };
in {
  imports = [./shpool.nix];

  home.packages =
    [
      emacs
    ]
    ++ (with pkgs; [
      emacsclient-commands
      sdcv
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
    ]);
  # sdcv's default search path, so the Emacs daemon needs no env var.
  home.file.".stardict/dic/web1913".source = web1913;

  services = {
    emacs = {
      client.enable = true;
      enable = true;
      package = emacs;
    };
  };
}
