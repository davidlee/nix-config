# The NixOS base's Linux machine and admin substrate, owned by
# environment.systemPackages.
{
  pkgs,
  lib,
  ...
}: {
  environment.systemPackages = with pkgs;
    [
      ## sandbox/container substrate
      bubblewrap
      distrobox
      distrobox-tui
      #devcontainer

      valgrind
      strace

      ## network
      iptraf-ng
      nethogs
      nmon
      vnstat

      ## hardware & disk inspection
      hdparm
    ]
    ++ lib.filter (lib.meta.availableOn pkgs.stdenv.hostPlatform) [pkgs.cpuid]
    ++ [
      cpuinfo
      dmidecode
      lshw
      pciutils
      smartmontools
      smem
      sysprof
      sysstat
      usbutils
    ]
    ++ lib.filter (lib.meta.availableOn pkgs.stdenv.hostPlatform) [pkgs.x86info]
    ++ [
      lm_sensors

      ## low-level debugging/tracing
      atop
      iotop

      ## systemd / logs
      isd
      lazyjournal
      systemctl-tui

      ## privileged automation
      ydotool
    ];
}
