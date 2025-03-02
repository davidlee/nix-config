
{
  lib,
  config,
  ...
}: 

with lib; let
  cfg = config.vm.guest-services;
in {

  environment.systemPackages = mkIf cfg.enable { with pkgs; [
    # environment.systemPackages = with pkgs; [
      qemu
      docker
      docker-compose
    ];
  };

  options.vm.guest-services = {
    enable = mkEnableOption "Enable Virtual Machine Guest Services";
  };

  config = mkIf cfg.enable {
    services.qemuGuest.enable = true;
    services.spice-vdagentd.enable = true;
    services.spice-webdavd.enable = true;

    virtualisation = {
      docker = {
        enable = true;
        enableOnBoot = true;
        rootless = {
          enable = true;
          setSocketVariable = true;
        };
      };
    };
  };

