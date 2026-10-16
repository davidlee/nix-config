# Data features, in projection order. Shape: README § Feature tree.
_: [
  {
    name = "structured";
    homeManager = {
      pkgs,
      lib,
      ...
    }: {
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
        ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
          ## csv
          csv-tui
        ];
    };
  }

  {
    name = "hex";
    homeManager = {
      pkgs,
      lib,
      ...
    }: {
      home.packages = lib.optionals pkgs.stdenv.hostPlatform.isLinux (with pkgs; [
        ## hex editors
        hexyl
        unixtools.xxd
      ]);
    };
  }
]
