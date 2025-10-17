_: let
  netPackages = pkgs:
    with pkgs; [
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
    ];
in {
  flake.nixosModules.net = {pkgs, ...}: {
    environment.systemPackages = netPackages pkgs;
  };

  flake.darwinModules.net = {pkgs, ...}: {
    environment.systemPackages = netPackages pkgs;
  };
}
