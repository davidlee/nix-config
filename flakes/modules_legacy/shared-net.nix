{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # network / http
    curl
    dig
    httpie
    iftop
    inetutils
    nmap
    netcat
    socat
    openssl
    oha
    sn0int
    tcpdump
    trippy
    wget
    xh
    yt-dlp
    # nextdns
  ];
}
