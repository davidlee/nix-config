# System features, in projection order. Shape: README § Feature tree.
{lib, ...}: let
  available = import ./available.nix lib;
in [
  {
    name = "monitor";
    homeManager = {pkgs, ...}: {
      home.packages = with pkgs;
        [
          glances
          btop
          bottom
        ]
        ++ available pkgs [
          ## systray
          tray-tui

          ## sysmon
          htop
          gtop
          wtf
        ];
    };
  }

  {
    name = "process";
    homeManager = {pkgs, ...}: {
      home.packages = available pkgs (with pkgs; [
        ## process management
        pstree
        killall
        await
        procs # ps but better
        pueue
        mprocs

        ## load test / benchmark
        stress-ng
      ]);
    };
  }
]
