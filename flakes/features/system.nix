# System features, in projection order. Shape: README § Feature tree.
_: [
  {
    name = "monitor";
    homeManager = {
      pkgs,
      lib,
      ...
    }: {
      home.packages = with pkgs;
        [
          glances
          btop
          bottom
        ]
        ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
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
    homeManager = {
      pkgs,
      lib,
      ...
    }: {
      home.packages = lib.optionals pkgs.stdenv.hostPlatform.isLinux (with pkgs; [
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
