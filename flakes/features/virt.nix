# Virtualisation features, in projection order. Shape: README § Feature tree.
[
  (import ./virt/capsule.nix)

  {
    name = "qemu";
    nixos = {
      pkgs,
      username,
      lib,
      ...
    }: {
      environment.systemPackages = with pkgs; [
        quickemu
        qemu_kvm
        #qemu_xen
        #qemu-utils
        #qemu-user
      ];

      virtualisation = {
        # xen.enable = true;
        libvirtd = {
          enable = true;
          qemu = {
            package = pkgs.qemu_kvm;
          };
        };
      };

      # libvirt's default NAT network: guests need dnsmasq (DHCP + DNS) on the
      # bridge. libvirt's own nftables accepts can't override the NixOS firewall's
      # input drop (a drop in any table is terminal), so open them here, scoped
      # to the bridge.
      networking.firewall.interfaces.virbr0 = {
        allowedUDPPorts = [53 67];
        allowedTCPPorts = [53];
      };

      users.groups.libvirtd.members = [username];
      programs.virt-manager.enable = true;

      systemd.services.libvirtd.wantedBy = lib.mkForce [];
      systemd.services.libvirt-guests.wantedBy = lib.mkForce [];
    };
  }

  {
    name = "docker";
    # Rootless only: no docker group, since nixpkgs creates it only for the
    # rootful daemon. Rootful is refused in modules/nixos/security.nix.
    nixos = {pkgs, ...}: {
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
    };
  }
]
