{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    ## security / crypto / secrets
    nvdtools
    seclists
    git-crypt
    gpgme
    gpg-tui
    oath-toolkit
    _1password-cli
  ];
}
