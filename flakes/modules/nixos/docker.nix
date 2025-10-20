_: {
  flake.nixosModules.virtualisation = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      docker
      docker-compose
      lazydocker
      gomanagedocker
      dive # inspect docker image layers
    ];

    virtualisation = {
      containers.enable = true;
      docker = {
        enable = true;
        # Set up resource limits
        daemon.settings = {
          experimental = true;
          default-address-pools = [
            {
              base = "172.30.0.0/16";
              size = 24;
            }
          ];
        };
        # Use the rootless mode - run Docker daemon as non-root user
        rootless = {
          enable = true;
          setSocketVariable = true;
        };
      };
    };
  };
}
