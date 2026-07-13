# parked
{pkgs, ...}: {
  # enable SSD trim & improve perf
  fileSystems."/".options = ["noatime" "nodiratime" "discard"];
}
