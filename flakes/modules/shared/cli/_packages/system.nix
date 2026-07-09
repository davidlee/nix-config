{pkgs, ...}: {
  ## userland system/process monitors (portable)
  common = with pkgs; [
    glances
    btop
    bottom
  ];

  ## userland system/process tools, Linux-only
  linuxHome = with pkgs; [
    ## disk & file io
    mmtui # mount manager
    udiskie

    ## systray
    tray-tui

    ## sysmon
    htop
    gtop
    wtf

    ## process management
    pstree
    killall
    await
    procs # ps but better
    pueue
    mprocs

    ## load test / benchmark
    stress-ng
    hyperfine
  ];

  ## machine/admin substrate: hardware inspection, systemd/log tooling,
  ## low-level debugging/tracing, privileged automation
  linuxSystem = with pkgs; [
    ## hardware & disk inspection
    hdparm
    cpuid
    cpuinfo
    dmidecode
    lshw
    pciutils
    smartmontools
    smem
    sysprof
    sysstat
    usbutils
    x86info
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
