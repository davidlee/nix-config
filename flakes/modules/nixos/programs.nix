{pkgs, ...}: {
  programs = {
    nix-ld = {
      enable = true;
      libraries = with pkgs; [
        #
        # List by default
        zlib
        zstd
        stdenv.cc.cc
        curl
        openssl
        attr
        libssh
        bzip2
        libxml2
        acl
        libsodium
        util-linux
        xz
        systemd
      ];
    };

    rust-motd = {
      enable = true;
      settings = {
      };
    };

    zsh = {
      enable = true;
    };
  };

  environment = {
    systemPackages = [
      pkgs.helix # root's editor
    ];
    pathsToLink = ["/share/zsh"];
  };
}
