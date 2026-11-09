# Net features, in projection order. Shape: README § Feature tree.
{lib, ...}: let
  available = import ./available.nix lib;
in [
  {
    name = "tools";
    homeManager = {pkgs, ...}: let
      # Vendored aws-lc: cargoSetupHook's system-lib mode fails this recipe
      # (ISS-028, probe in workarounds/default.nix).
      oha = pkgs.oha.overrideAttrs {dontCargoUseSystemLibs = true;};
    in {
      home.packages = with pkgs;
        [
          aria2
          curlie
          dig
          ngrok
          httpie
          iftop
          inetutils
          nmap
          netcat
          socat
          oha
          tcpdump
          trippy
          xh # http tool
          yt-dlp
          unixtools.net-tools
          doggo
          bandwhich # whats eating the network
          lsof
        ]
        ++ available pkgs [
          sn0int
        ];
    };
    nixos = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [
        iptraf-ng
        nethogs
        nmon
        vnstat
      ];
    };
  }

  # Daemon and tray travel together (DEC-042). The tray is PartOf/WantedBy
  # graphical-session.target, so it stays inert on a headless host.
  {
    name = "tailscale";
    platforms = lib.platforms.linux;
    nixos = _: {
      services.tailscale.enable = true;
    };
    homeManager = _: {
      services.tailscale-systray.enable = true;
    };
  }
]
