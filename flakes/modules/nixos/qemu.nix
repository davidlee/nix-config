_: {
  flake.nixosModules.qemu = {
    pkgs,
    username,
    lib,
    ...
  }: {
    environment.systemPackages = with pkgs; [
      quickemu
      qemu
      #qemu_full
      #qemu_kvm
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

    users.groups.libvirtd.members = [username];
    programs.virt-manager.enable = true;

    systemd.services.libvirtd.wantedBy = lib.mkForce [];
    systemd.services.libvirt-guests.wantedBy = lib.mkForce [];
  };
}
