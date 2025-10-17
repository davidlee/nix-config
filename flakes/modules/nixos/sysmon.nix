{pkgs, ...}: {
  flake.nixosModules.sysmon = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      ccache
      cpuid
      cpuinfo
      dmidecode
      lshw
      pciutils
      smem
      stress-ng
      sysprof
      sysstat
      usbutils
      x86info
      lm_sensors
      atop
      iotop
      bottom
      btop
      glances
      htop
      gtop
    ];
  };
}
