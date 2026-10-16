# Security features, in projection order. Shape: README § Feature tree.
_: [
  {
    name = "credentials";
    homeManager = {pkgs, ...}: {
      home.packages = with pkgs; [
        git-crypt
        gpgme
        gpg-tui
        oath-toolkit
      ];
    };
    nixos = {pkgs, ...}: {
      programs._1password.enable = true;
      environment.systemPackages = [pkgs._1password-cli];
    };
  }

  {
    name = "research";
    homeManager = {pkgs, ...}: {
      home.packages = with pkgs; [
        nvdtools
        seclists
      ];
    };
  }
]
