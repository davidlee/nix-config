# What Sleipnir physically is: hand-written config bound to its parts (DEC-019).
#
# ./hardware-configuration.nix beside it is generated (`just
# regenerate-hardware`) and must not be edited. Generic hardware support that
# any host may select is a feature (features/hardware.nix), not machine config.
#
# Here too: the Radeon GPU (once modules/nixos/radeon.nix), its devices'
# kernel blacklist, the NIC's NetworkManager profile, and nix build limits and
# swap sized to its CPU, RAM and disk.
{
  inputs,
  pkgs,
  username,
  ...
}: {
  imports = [inputs.ucodenix.nixosModules.default];

  boot = {
    kernelModules = ["amdgpu"];

    kernelParams = [
      # CPU microcode for the 9950X. ucodenix asks for amd_sha_check=off and warns
      # without it: https://github.com/e-tho/ucodenix?tab=readme-ov-file#3-apply-changes
      "microcode.amd_sha_check=off"

      # GPU hang recovery: a wedged context is reset (seconds) instead of
      # locking the whole display to 0fps for minutes. gpu_recovery=1 forces
      # reset on hang; reset_method is left at auto so amdgpu picks the mode
      # supported by Navi 48 (RDNA4).
      "amdgpu.gpu_recovery=1"
    ];

    blacklistedKernelModules = [
      "ucsi_ccg"
      "vc032x"
      "gspca_vc032x"
    ];
  };

  services = {
    ucodenix = {
      enable = true;
      cpuModelId = "00B40F40"; # 9950x ;  Current revision: 0x0b404023
    };

    xserver.videoDrivers = ["modesetting"];
  };

  # enable SSD trim & improve perf
  fileSystems."/".options = ["noatime" "nodiratime" "discard"];

  # 16G swap file on root (ext4) — supplements the 8.8G swap partition
  swapDevices = [
    {
      device = "/swapfile";
      size = 16384;
    }
  ];

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        rocmPackages.clr.icd
      ];
    };

    amdgpu = {
      opencl.enable = true;
    };

    i2c.enable = true;
  };

  # the GPU is why the user needs `video`
  users.users.${username}.extraGroups = ["video"];

  networking.networkmanager.ensureProfiles.profiles.wired = {
    connection = {
      id = "wired";
      type = "ethernet";
      interface-name = "enp8s0";
    };
    # Static IP owned declaratively by this profile (not a router DHCP
    # reservation). keyfile format: address1 = "IP/prefix,gateway".
    ipv4 = {
      method = "manual";
      address1 = "192.168.0.9/24,192.168.0.1";
      ignore-auto-dns = true;
    };
    ipv6 = {
      method = "auto";
      ignore-auto-dns = true;
    };
  };

  nix.settings = {
    max-jobs = 4;
    cores = 4;
  };

  environment = {
    systemPackages = with pkgs; [
      ## rocm CLR
      clinfo
      rocmPackages.clr.icd
      rocmPackages.rocminfo
      # rocmPackages.opt-rocm

      ## overclocky
      lact

      ## tools
      radeon-profile
      vulkan-tools

      ## info
      wgpu-utils
    ];
  };

  systemd = {
    # create a linked path for rocm libraries that might be hardcoded in
    # various libraries and packages
    tmpfiles.rules = let
      rocmEnv = pkgs.symlinkJoin {
        name = "opt-rocm";
        paths = with pkgs.rocmPackages; [
          rocblas
          hipblas
          clr
        ];
      };
    in [
      "L+    /opt/rocm   -    -    -     -    ${rocmEnv}"
    ];

    packages = with pkgs; [lact];
    services = {
      lactd.wantedBy = ["multi-user.target"];

      # Cap nix-daemon memory so heavy builds (rust links) don't swap out the desktop
      # and freeze the cursor. Soft limit: kernel reclaims nix-daemon's own pages and
      # throttles its allocations past 40G rather than OOM-killing the build. Leaves
      # ~20G for sway + apps + page cache. Bump if builds thrash inside the cgroup.
      nix-daemon.serviceConfig.MemoryHigh = "40G";
    };
  };
}
