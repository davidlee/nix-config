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
    docker
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
  };
  
  users.groups.incus-admin.members = [ username ];
  users.groups.incus.members = [ username ];
  users.groups.libvirtd.members = [ username ];
  programs.virt-manager.enable = true;

  # virtualisation = {
  #   spiceUSBRedirection.enable = true;
  #   libvirtd.enable = true;
  #   docker = {
  #     enable = true;
  #     enableOnBoot = true;
  #     rootless = {
  #       enable = true;
  #       setSocketVariable = true;
  #     };
  #   };
  # };
}

