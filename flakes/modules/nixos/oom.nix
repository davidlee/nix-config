_: {
  flake.nixosModules.oom = _: {
    # tune systemd-oomd to intervene before the system becomes unresponsive
    systemd.oomd = {
      enable = true;
      enableRootSlice = true;
      enableUserSlices = true;
      enableSystemSlice = true;
      settings.OOM = {
        SwapUsedLimit = "90%";
        DefaultMemoryPressureDurationSec = "20s";
      };
    };

    # reserve resources for the compositor and login session
    # ensures sway + a rescue terminal always get CPU time and memory
    systemd.slices."user-1000" = {
      sliceConfig = {
        CPUWeight = 200;
        MemoryLow = "512M";
      };
    };

    # 16G swap file on root (ext4) — supplements the 8.8G swap partition
    swapDevices = [
      {
        device = "/swapfile";
        size = 16384;
      }
    ];

    # zswap too
    zramSwap = {
      enable = true;
      memoryPercent = 50;
      priority = 100;
      algorithm = "zstd";
    };

    # zswap: compress swap pages in RAM before writing to disk
    boot.kernelParams = ["zswap.enabled=1" "zswap.compressor=zstd" "zswap.zpool=zsmalloc"];
    boot.kernel.sysctl = {
      "vm.swappiness" = 60;
    };
  };
}
