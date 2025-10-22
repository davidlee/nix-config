_: {
  flake.nixosModules.podman = {
    pkgs,
    username,
    ...
  }: {
    environment.systemPackages = with pkgs; [
      podman
      podman-compose
      podman-desktop
      podman-tui
      distrobox
      crun # needed for distrobox
    ];
    virtualisation = {
      containers.enable = true;
      podman = {
        enable = true;
        dockerCompat = true;
        defaultNetwork.settings.dns_enabled = true; # Required for containers under podman-compose to be able to talk to each other.
      };
    };

    users.users.${username} = {
      extraGroups = ["podman"];
    };
  };
}
