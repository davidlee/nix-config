# Data features, in projection order. Shape: README § Feature tree.
{lib, ...}: let
  available = import ./available.nix lib;
in [
  {
    name = "structured";
    homeManager = {pkgs, ...}: {
      home.packages = with pkgs;
        [
          ## CSV
          # tidy-viewer

          ## JSON / YAML
          otree # text object tree viewer
          gron
          jq
          xq
          jqp # jq tui playground
          yq-go # jq for yaml
          jc
          jless
        ]
        ++ available pkgs [
          ## csv
          csv-tui
        ];
    };
  }

  {
    name = "hex";
    homeManager = {pkgs, ...}: {
      home.packages = available pkgs (with pkgs; [
        ## hex editors
        hexyl
        unixtools.xxd
      ]);
    };
  }
]
