# Text features, in projection order. Shape: README § Feature tree.
{lib, ...}: let
  available = import ./available.nix lib;
in [
  {
    name = "tools";
    homeManager = {pkgs, ...}: {
      home.packages = with pkgs;
        [
          ## regex
          grex

          sd
          play # playground for sed, grep, awk, ...
          choose
          slides
        ]
        ++ available pkgs [
          ### unicode
          cicero-tui # unicode
        ];
    };
  }

  {
    name = "pagers";
    homeManager = {pkgs, ...}: {
      home.packages = with pkgs;
        [
          ## text readers, pagers
          nvimpager
          most
          moor
          ov

          ## highlighting
          chroma
        ]
        ++ available pkgs [
          fltrdr
        ];
    };
  }

  # sdcv and the web1913 dictionary are unguarded: they came from emacs.nix,
  # which every home imported (quick-sdcv in Emacs reads them).
  {
    name = "dictionary";
    homeManager = {pkgs, ...}: let
      # Webster's Revised Unabridged Dictionary (1913), StarDict format, read by
      # sdcv (quick-sdcv in Emacs). Public domain.
      web1913 = pkgs.fetchzip {
        url = "https://raw.githubusercontent.com/ahacop/websters-dict-1913-stardict/7f9c6d6725eb1b0d8545a6f74904610fa2a2c71e/stardict-dictd-web1913-2.4.2.tgz";
        hash = "sha256-wEnu6azvGJt8bxWd/lZGuiFwEP+l+gpxD1e+7CI7tz0=";
      };
    in {
      home.packages = with pkgs;
        [
          aspell
          sdcv
        ]
        ++ available pkgs [
          ## translate
          gtt
        ];
      # sdcv's default search path, so the Emacs daemon needs no env var.
      home.file.".stardict/dic/web1913".source = web1913;
    };
  }
]
