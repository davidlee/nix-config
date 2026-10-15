# What Sleipnir physically is: hand-written config bound to its parts (DEC-019).
#
# ./hardware-configuration.nix beside it is generated (`just
# regenerate-hardware`) and must not be edited. Generic hardware support that
# any host may select is a feature (features/hardware.nix), not machine config.
{inputs, ...}: {
  imports = [inputs.ucodenix.nixosModules.default];

  # CPU microcode for the 9950X. ucodenix asks for amd_sha_check=off and warns
  # without it: https://github.com/e-tho/ucodenix?tab=readme-ov-file#3-apply-changes
  boot.kernelParams = ["microcode.amd_sha_check=off"];

  services.ucodenix = {
    enable = true;
    cpuModelId = "00B40F40"; # 9950x ;  Current revision: 0x0b404023
  };

  # enable SSD trim & improve perf
  fileSystems."/".options = ["noatime" "nodiratime" "discard"];
}
