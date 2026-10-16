# Office features, in projection order. Shape: README § Feature tree.
_: [
  {
    name = "calc";
    homeManager = {pkgs, ...}: {
      home.packages = with pkgs; [
        bc
        eva
        sc-im
      ];
    };
  }

  {
    name = "calendar";
    homeManager = {
      pkgs,
      lib,
      ...
    }: {
      home.packages = with pkgs;
        [
          ### google cal
          gcalcli

          # calendar-cli # disabled: test failures in python3.13-niquests dep
          calcure
        ]
        ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
          mpris-timer # aka play timer
        ];
    };
  }
]
