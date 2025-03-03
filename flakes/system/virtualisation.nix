{
  pkgs,
  ...
}: {
  
  environment.systemPackages =  with pkgs; [
    qemu
    docker
    docker-compose
  ];

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
}

