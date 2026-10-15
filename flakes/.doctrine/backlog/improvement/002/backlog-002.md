# IMP-002: Private flake input for host-local identifiers

From TODO.md. Keep identifiers such as the ControlD profile hostname (`modules/nixos/network.nix`) out of the public repo via a local-only non-flake input (`git+file:///home/david/nix-private`, `flake = false`). Then regenerate the ControlD profile so the leaked hostname becomes inert. Scales to printer MAC, LAN IPs, tailnet names. Real secrets graduate to sops-nix/agenix instead. Full sketch in TODO.md.
