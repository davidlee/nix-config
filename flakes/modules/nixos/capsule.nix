# The host side of ~/dev/microvm-spike's agent capsule: the allowlist egress
# proxy, as a unit under its own system uid instead of as a child of
# `capsule-host` running as me. tinyproxy parses guest-authored HTTP, which does
# not belong on an account holding ~/.ssh, ~/.claude and every repo on the
# machine.
#
# It was two units. The other was a git daemon serving a mirror the guest pushed
# to; the host initiates git in both directions over ssh now, so the daemon, its
# uid, the mirror, the `capsule-git` group and the second port are gone rather
# than hardened (microvm-spike NOTES item 18). A rebuild therefore drops my
# `capsule-git` membership, because the group no longer exists.
#
# The rest of the perimeter stays this host's own config, where the guest cannot
# reach it, and the module verifies rather than restates it:
#   - network.nix — the FORWARD drop on the tap, and the interface-scoped port
#     (3128 only, since item 18).
#   - security.nix — the read-only `nft list table inet capsule-forward` sudo
#     rule, still needed by the devshell path (`capsule-host`, `just verify`).
# capsule-perimeter-guard.service does the same check as root, and the proxy
# BindsTo it, so an unverifiable-and-forwarding host cannot serve egress.
#
# Neither unit is enabled at boot (the proxy is conditional on the tap
# existing). Start them by hand after `capsule-net up`. Nothing here reads
# ~/dev/doctrine: `capsule-provision` and `capsule-collect` are mine to run and
# are installed system-wide by the module, wrapped onto its state directory.
{
  inputs,
  username,
  ...
}: {
  imports = [inputs.microvm-spike.nixosModules.capsule-perimeter];

  services.capsule-perimeter = {
    enable = true;
    # Owns the quarantine repositories `capsule-collect` fetches into, and gets
    # the proxy's egress log by group. Never runs the service. `repo` and
    # `allowlist` default under /home/${username}/dev, which is where both live.
    owner = username;
  };
}
