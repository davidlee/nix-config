{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # ## SCM
    sublime-merge

    # ## keyboard firmware
    qmk-udev-rules

    # ## lang.c
    valgrind
    strace

    # ## servers
    caddy

    ## database
    sqlite
    # gobang
    # lazysql
    # rainfrog
    # stable.harlequin
    # vi-mongo
  ];
}
