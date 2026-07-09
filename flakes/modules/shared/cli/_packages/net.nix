{pkgs, ...}: {
  common = with pkgs; [
    curl
    curlie
    dig
    ngrok
    httpie
    iftop
    inetutils
    nmap
    netcat
    socat
    openssl
    oha
    tcpdump
    trippy
    wget
    xh # http tool
    yt-dlp
    unixtools.net-tools
    doggo
    bandwhich # whats eating the network
    ddgr # search duckduckgo
    lsof
  ];
  linuxHome = with pkgs; [
    sn0int
  ];
  linuxSystem = with pkgs; [
    iptraf-ng
    nethogs
    nmon
    vnstat
  ];
}
