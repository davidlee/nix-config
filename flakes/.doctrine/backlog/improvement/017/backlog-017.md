# IMP-017: Site-bound config: home-LAN printers and network

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

Raised during SL-005 design review (2026-10-15). DEC-019 puts config bound to
one machine's *parts* in `hosts/<h>/hardware.nix`. A second category isn't
covered: config bound to the *site*, meaning the home network and the devices
on it. Two modules mix it with generic config:

**`modules/nixos/printing.nix`** (legacy flag `printing`, a W3 singleton)
- site: `brlaser` for the Brother HL-L2445DW, gutenprint for the Canon;
  `networking.extraHosts` with the printer's IP and mDNS name (CUPS' ipp
  backend can't resolve `.local` in its sandbox)
- generic: CUPS, `system-config-printer`

**`modules/nixos/network.nix`** (unconditional; RFC-001 W4 already names its
`enp8s0` profile as a split)
- host: NIC `enp8s0`
- host-on-site: static `192.168.0.9/24`
- site: gateway `192.168.0.1`
- account: the ControlD profile hostname in stubby (IMP-002)
- generic base: NetworkManager, resolved and stubby, firewall, nftables,
  tailscale, gai.conf, timeservers

Decide:
1. Where site config lives. Options: a `site` module or profile (for example
   `sites/home.nix`) that hosts on that LAN import, or host config
   (DEC-019 style) while there is only one host.
2. How generic modules take site values. Options: typed options on a
   feature (printers, LAN), or the site module setting upstream options
   directly.

When: W4 for `network.nix`, the W3 singletons slice for `printing`.
Related: IMP-002 (keep LAN IPs and identifiers out of the public repo),
DEC-019, RFC-001 W4.
