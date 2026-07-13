{pkgs, ...}: {
  # tune systemd-oomd to intervene before the system becomes unresponsive.
  # oomd fires early on PSI memory-pressure across cgroups.
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

  # earlyoom: hard backstop below oomd. Reacts to absolute free memory,
  # so it fires in a true crunch even if PSI hasn't tripped. Prefers to
  # kill browser/electron hogs; refuses to touch the compositor/session.
  services.earlyoom = {
    enable = true;
    freeMemThreshold = 5; # SIGTERM the biggest scored proc under 5% free RAM
    freeSwapThreshold = 10;
    enableNotifications = true;
    extraArgs = [
      "--prefer"
      "(^|/)(electron|chrome|chromium|firefox|node|.*-app)$"
      "--avoid"
      "(^|/)(sway|Xwayland|waybar|systemd|systemd-oomd|pipewire|wireplumber|dbus)$"
    ];
  };

  # reserve resources for the compositor and login session
  # ensures sway + a rescue terminal always get CPU time and memory
  systemd.slices."user-1000" = {
    sliceConfig = {
      CPUWeight = 200;
      MemoryLow = "512M";
    };
  };

  # `leash CMD ARGS…` — run an untrusted app in a transient, resource-capped
  # scope. If it goes rogue it dies alone; the desktop is never starved.
  # Override caps per-launch: LEASH_MEM=4G LEASH_CPU=400% leash some-app.
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "leash" ''
      set -eu
      if [ "$#" -eq 0 ]; then
        echo "usage: leash [--] CMD [ARGS…]   (caps: LEASH_MEM/LEASH_MEM_HIGH/LEASH_CPU)" >&2
        exit 64
      fi
      [ "$1" = "--" ] && shift
      exec ${pkgs.systemd}/bin/systemd-run --user --scope --quiet \
        --unit="leash-$(basename "$1")-$$" \
        -p MemoryMax="''${LEASH_MEM:-8G}" \
        -p MemoryHigh="''${LEASH_MEM_HIGH:-6G}" \
        -p CPUQuota="''${LEASH_CPU:-800%}" \
        -p ManagedOOMMemoryPressure=kill \
        -p ManagedOOMMemoryPressureLimit=80% \
        -- "$@"
    '')
  ];

  # 16G swap file on root (ext4) — supplements the 8.8G swap partition
  swapDevices = [
    {
      device = "/swapfile";
      size = 16384;
    }
  ];

  # zram: compressed swap in RAM (fast). This is the primary swap tier.
  zramSwap = {
    enable = true;
    memoryPercent = 50;
    priority = 100;
    algorithm = "zstd";
  };

  # NOTE: zswap is intentionally NOT enabled. zswap compresses pages then
  # writes them to a backing swap device — stacking it on zram would
  # double-compress. With zram as the swap tier, zswap is redundant.
  # High swappiness so the kernel prefers cheap zram over disk swap.
  boot.kernel.sysctl = {
    "vm.swappiness" = 150;
  };
}
