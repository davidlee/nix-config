_: let
  secPackages = pkgs:
    with pkgs; [
      #
      ## security / crypto / secrets
      nvdtools
      seclists
      git-crypt
      gpgme
      gpg-tui
      oath-toolkit
    ];
in {
  flake.nixosModules.sec = {pkgs, ...}: {
    environment.systemPackages = secPackages pkgs;
  };

  flake.darwinModules.sec = {pkgs, ...}: {
    environment.systemPackages = secPackages pkgs;
  };
}
