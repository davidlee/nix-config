{
  pkgs,
  username,
  ...
}: {
  
  environment.systemPackages =  with pkgs; [
    nemu
    qemu
    qemu_full
    qemu_kvm
    qemu_xen
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
      # ui.enable = true;
      # agent.enable = true;
    };
    
    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        # runAsRoot = true;
        # swtpm.enable = true;
        # ovmf = { };
      };
    };

    containers.enable = true;

    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };
  
  users.groups.incus-admin.members = [ username ];
  users.groups.incus.members = [ username ];
  users.groups.libvirtd.members = [ username ];
  programs.virt-manager.enable = true;
}

