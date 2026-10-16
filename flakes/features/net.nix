# Net features, in projection order. Shape: README § Feature tree.
{lib, ...}: let
  available = import ./available.nix lib;
in [
  {
    name = "tools";
    homeManager = {pkgs, ...}: {
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
  }
]
