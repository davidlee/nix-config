{
  pkgs,
  lib,
  ...
}: let
  cli = import ../../shared/cli {inherit pkgs lib;};
in {
  home.packages = cli.common ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux cli.linuxHome;
}
