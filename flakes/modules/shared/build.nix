_: let
  buildPackages = pkgs:
    with pkgs; [
      ## build tools
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
in {
  flake.nixosModules.build = {pkgs, ...}: {
    environment.systemPackages = buildPackages pkgs;
  };

  flake.darwinModules.build = {pkgs, ...}: {
    environment.systemPackages = buildPackages pkgs;
  };
}
