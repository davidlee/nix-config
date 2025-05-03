{
  pkgs,
  username,
  lib,
  ...
}: {
  
  environment.systemPackages =  with pkgs; [
    quickemu
    # darling 
    nemu
    qemu
    qemu_full
    qemu_kvm
    # qemu_xen
    qemu-utils
    qemu-user
    distrobox
    distrobox-tui
    dive # inspect docker image layers
    podman
    podman-compose
    podman-desktop
    podman-tui
    # docker
    docker-compose
    virt-manager
    lxc
    lxd-lts
    incus
  ];

  virtualisation = {
    incus = {
      enable = true;
    };
    
    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
      };
    };

    containers.enable = true;

    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };

    lxd = {
      enable = true;
    };
  };
  
  users.groups.incus-admin.members = [ username ];
  users.groups.incus.members = [ username ];
  users.groups.libvirtd.members = [ username ];
  programs.virt-manager.enable = true;

  # leave services idle by default; start with systemctl or by poking them on the cli
  systemd.services.incus-startup.wantedBy = lib.mkForce [];
  systemd.services.incus.wantedBy = lib.mkForce [];
  systemd.services.libvirtd.wantedBy = lib.mkForce [];
  systemd.services.libvirt-guests.wantedBy = lib.mkForce [];
  systemd.services.docker.wantedBy = lib.mkForce [];
  # systemd.services.lxd.wantedBy = lib.mkForce [];

}

