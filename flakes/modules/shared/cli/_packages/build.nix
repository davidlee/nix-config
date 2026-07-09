{pkgs, ...}: {
  common = with pkgs; [
    ## build tools
    gnumake
    ninja
    autoconf
    cmake
    # redo-apenwarr

    ## parse / lex
    bison

    ## lang.c
    gcc
  ];
  linuxHome = with pkgs; [
    lldb
    lld
    llvm
    clangStdenv
    libclang
    binutils
  ];
}
