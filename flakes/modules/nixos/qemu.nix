{
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
}
