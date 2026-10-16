# The NixOS base's inspection set: tracing, hardware and disk inspection,
# resource monitors and systemd/log tools, owned by environment.systemPackages.
{
  pkgs,
  lib,
  ...
}: {
  environment.systemPackages = with pkgs;
    [
      strace

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
    ];
}
