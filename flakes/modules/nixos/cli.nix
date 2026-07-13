{
  pkgs,
  lib,
  ...
}: {
  environment.systemPackages = (import ../shared/cli {inherit pkgs lib;}).linuxSystem;
}
