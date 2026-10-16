# Net features, in projection order. Shape: README § Feature tree.
_: [
  {
    name = "tools";
    homeManager = {
      pkgs,
      lib,
      ...
    }: {
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
        ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
          sn0int
        ];
    };
  }
]
