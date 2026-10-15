# The host side of oubliette's agent capsule — the repo is still checked out at
# ~/dev/microvm-spike, which is what the module's `repo` and `allowlist` defaults
# spell, so the directory outlives the rename. The allowlist egress
# proxy, as a unit under its own system uid instead of as a child of
# `capsule-host` running as me. tinyproxy parses guest-authored HTTP, which does
# not belong on an account holding ~/.ssh, ~/.claude and every repo on the
# machine.
#
# It was two units. The other was a git daemon serving a mirror the guest pushed
# to; the host initiates git in both directions over ssh now, so the daemon, its
# uid, the mirror, the `capsule-git` group and the second port are gone rather
# than hardened (oubliette NOTES item 18). A rebuild therefore drops my
# `capsule-git` membership, because the group no longer exists.
#
# Two shapes now, one at a time, and the module refuses to run both:
#   - the devshell path (`capsule-net up && capsule-host`) puts the tap in the
#     root namespace, so its perimeter is still partly this host's own config —
#     the FORWARD drop on the tap and the interface-scoped port 3128, plus the
#     read-only `nft list table inet capsule-forward` sudo rule that lets an
#     unprivileged `capsule-host` read the drop. Those three, and the `assigner`
#     user, are below; they serve only this path.
#   - the unit path puts each capsule's tap inside its own network namespace, so
#     the control is that namespace's `ip_forward` and none of the above applies
#     to it. What it does need — forwarding, NAT, the resolver stub on the
#     capsule-facing link, the port-53 allow — the module installs itself.
# capsule-perimeter-guard.service verifies whichever holds, as root, and the
# proxies BindsTo it: unverifiable-and-forwarding serves no egress.
#
# Nothing starts at boot. Per capsule, `microvm@<name>` pulls its namespace, its
# tap, its proxy and its ssh relay up with it, and that is started by hand.
# Nothing here reads ~/dev/doctrine: `capsule-provision` and `capsule-collect`
# are mine to run and are installed system-wide by the module, wrapped onto its
# state directory.
{
  name = "capsule";
  nixos = {
    inputs,
    username,
    ...
  }: {
    imports = [
      # microvm.nix's host half: the `microvm@` and `microvm-tap-interfaces@`
      # templates the perimeter module hangs its per-capsule drop-ins off, plus
      # /var/lib/microvms. Taken through oubliette rather than as an input of
      # its own so there is one locked microvm.nix on this machine, and because its
      # `nixpkgs` already follows this flake's.
      #
      # `microvm.vms.<name>` stays unused on purpose: declaring a VM here would
      # make this config evaluate the guest closure, which is the thing
      # `target.follows` exists to prevent. The VM is created imperatively
      # (`microvm -c capsule -f …#capsule`) and started by hand — nothing
      # autostarts, since a capsule at boot is a capsule nobody asked for.
      inputs.oubliette.inputs.microvm.nixosModules.host
      inputs.oubliette.nixosModules.capsule-perimeter
    ];

    microvm.host.enable = true;

    services.capsule-perimeter = {
      enable = true;
      # Owns the quarantine repositories `capsule-collect` fetches into, and gets
      # the proxy's egress log by group. Never runs the service. `repo` and
      # `allowlist` default under /home/${username}/dev, which is where both live.
      owner = username;
    };

    # The devshell path's perimeter. The unit path installs its own (oubliette
    # host/netns.nix).
    networking = {
      # Also set host-wide in modules/nixos/network.nix: it picks the firewall
      # backend for the whole host, and the table below needs it.
      nftables.enable = true;

      # The capsule's point-to-point tap, scoped to the one service the guest is
      # meant to reach: the egress proxy. 9418 was the second, a git daemon the
      # guest pushed to; the host initiates git in both directions over ssh now,
      # so there is no service behind that port and nothing to allow (oubliette
      # NOTES item 18).
      # NOT trustedInterfaces: that accepts everything on the iface, which put
      # every 0.0.0.0-bound host service (sshd, caddy on 80/8080, …) inside the
      # jail's reach. Interface-scoped rather than allowedTCPPorts, which would
      # also open this on enp8s0 and tailscale0.
      firewall.interfaces."vm-capsule".allowedTCPPorts = [3128];

      # The tap is an endpoint, never a transit path. The guest has no default
      # route, but a guest that gains root can add one, and then the only thing
      # between it and the LAN is whether this host forwards —
      # `net.ipv4.ip_forward` is global and both docker and tailscale turn it on
      # for their own reasons, so it cannot be left to inspection.
      #
      # Its own table, not `networking.firewall.filterForward`: that switches the
      # whole host's forward policy to drop and would take those same daemons
      # out. A `drop` verdict is terminal in any chain, so a separate table needs
      # no cooperation from the firewall's.
      #
      # `capsule-host` and `capsule-net` verify this table is present and refuse
      # to run without it once forwarding is live (see the sudo read rule
      # below). Renaming the table or the rules breaks that check.
      nftables.tables.capsule-forward = {
        family = "inet";
        content = ''
          chain forward {
            type filter hook forward priority filter - 10; policy accept;
            iifname "vm-capsule" drop
            oifname "vm-capsule" drop
          }
        '';
      };
    };

    # Read-only, and it is what lets ~/dev/microvm-spike's capsule-host
    # verify that the FORWARD drop on the tap (above) is actually
    # loaded, rather than trusting that the host config still says so.
    # Without this the check degrades to "unverifiable", which is
    # fail-closed once forwarding goes live.
    #
    # /run/current-system/sw/bin, not a store path: the checking script
    # lives in another flake with its own nixpkgs pin and has to name the
    # same string this rule does. sudo matches the command literally,
    # arguments included, so this grants exactly this one read.
    #
    # Plain priority: sudoers is last-match-wins, and nixpkgs puts its blanket
    # root and %wheel rules at mkOrder 400/600, so this always renders after
    # them.
    security.sudo.extraRules = [
      {
        users = [username];
        commands = [
          {
            command = "/run/current-system/sw/bin/nft list table inet capsule-forward";
            options = ["NOPASSWD"];
          }
        ];
      }
    ];

    # Extra unprivileged user for oubliette.
    users.users.assigner.isNormalUser = true;
  };
}
