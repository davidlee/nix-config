{pkgs, ...}: {
  ## security / crypto / secrets
  common = with pkgs; [
    nvdtools
    seclists
    git-crypt
    gpgme
    gpg-tui
    gnupg
    oath-toolkit
  ];
}
