# Virtualisation features, in projection order. Shape: README § Feature tree.
_: [
  (import ./virt/capsule.nix)

  # Sandbox/container substrate, without a container engine.
  {
    name = "sandbox";
    nixos = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [
        bubblewrap
        distrobox
        distrobox-tui
        #devcontainer
      ];
    };
  }

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
    nixos = {
      pkgs,
      config,
      ...
    }: {
      # Both ship bin/docker (podman via dockerCompat) and system-path keeps
      # whichever is listed first, silently (DEC-022). Tests the option, not
      # the feature, so podman switched on by any module is caught.
      assertions = [
        {
          assertion = !config.virtualisation.podman.enable;
          message = "virt.docker and virt.podman are exclusive: both provide bin/docker. Deselect one (IMP-018: podman replaces docker).";
        }
      ];

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

  # Selected by no host (DEC-022); evaluated by coverage."Sleipnir+podman".
  {
    name = "podman";
    nixos = {
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
]
