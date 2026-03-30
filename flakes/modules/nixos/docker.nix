_: {
  flake.nixosModules.docker = {
    pkgs,
    username,
    ...
  }: {
    environment.systemPackages = with pkgs; [
      docker
      docker-compose
      lazydocker
      # gomanagedocker
      # dive # inspect docker image layers
    ];

    virtualisation = {
      containers.enable = true;
      docker = {
        enable = false; # security yo

        # Use the rootless mode - run Docker daemon as non-root user
        rootless = {
          enable = true;
          setSocketVariable = true;
          daemon.settings = {
            dns = ["76.76.2.22" "2606:1a40::22"];
          };
        };
      };
    };

    users.users.${username} = {
      extraGroups = ["docker"];
    };
  };
}
