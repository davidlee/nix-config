{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    ## build systems
    gnumake
    ninja
    autoconf
    cmake
    # redo-apenwarr

    ## parse / lex
    bison

    ## lang.c
    lldb
    lld
    llvm
    gcc
    clangStdenv
    libclang
  ];
}
