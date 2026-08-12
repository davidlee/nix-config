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
#     network.nix's FORWARD drop on the tap and the interface-scoped port 3128,
#     plus security.nix's read-only `nft list table inet capsule-forward` sudo
#     rule that lets an unprivileged `capsule-host` read the drop.
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
}
