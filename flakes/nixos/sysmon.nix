{
  pkgs,
  username,
  ...
}: {
  environment.systemPackages = with pkgs; [
    ## low level / system monitoring
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

    ## system monitors
    atop
    iotop
  ];
}
