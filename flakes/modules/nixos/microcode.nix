{...}: {
  flake.nixosModules.microcode = {inputs, ...}: {
    imports = [inputs.ucodenix.nixosModules.default];

    boot = {
      # see https://github.com/e-tho/ucodenix?tab=readme-ov-file#3-apply-changes
      kernelParams = [
        "boot.shell_on_fail"
        "microcode.amd_sha_check=off"
      ];
    }; # /boot

    services = {
      ucodenix = {
        enable = true;
        cpuModelId = "00B40F40"; # 9950x ;  Current revision: 0x0b404023
      };
    };
  };
}
