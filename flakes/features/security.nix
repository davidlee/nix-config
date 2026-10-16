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
