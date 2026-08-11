# The host side of ~/dev/microvm-spike's agent capsule: the allowlist egress
# proxy and the git mirror daemon, as units under their own system uids instead
# of as children of `capsule-host` running as me. tinyproxy parses
# guest-authored HTTP and git-daemon runs `receive-pack`; neither belongs on an
# account holding ~/.ssh, ~/.claude and every repo on the machine.
#
# The rest of the perimeter stays this host's own config, where the guest cannot
# reach it, and the module verifies rather than restates it:
#   - network.nix — the FORWARD drop on the tap, and the interface-scoped ports.
#   - security.nix — the read-only `nft list table inet capsule-forward` sudo
#     rule, still needed by the devshell path (`capsule-host`, `just verify`).
# capsule-perimeter-guard.service does the same check as root, and both services
# BindsTo it, so an unverifiable-and-forwarding host cannot serve egress.
#
# Neither unit is enabled at boot (both are conditional on the tap existing).
# Start them by hand after `capsule-net up`, and run `capsule-sync` first — it
# runs as me and is the only thing that reads ~/dev/doctrine.
{
  inputs,
  username,
  ...
}: {
  imports = [inputs.microvm-spike.nixosModules.capsule-perimeter];

  services.capsule-perimeter = {
    enable = true;
    # Syncs the mirror and fetches the guest's capsule/* branches back out of
    # it. Never runs either service. `repo` and `allowlist` default under
    # /home/${username}/dev, which is where both live.
    owner = username;
  };
}
