# Office features, in projection order. Shape: README § Feature tree.
{lib, ...}: let
  available = import ./available.nix lib;
in [
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
    homeManager = {pkgs, ...}: {
      home.packages = with pkgs;
        [
          ### google cal
          gcalcli

          # calendar-cli # disabled: test failures in python3.13-niquests dep
          calcure
        ]
        ++ available pkgs [
          mpris-timer # aka play timer
        ];
    };
  }
]
