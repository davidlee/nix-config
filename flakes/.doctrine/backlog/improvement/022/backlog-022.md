# IMP-022: Parametrise oom.nix for hosts other than Sleipnir

`oom.nix` (systemd-oomd, earlyoom, zram, swappiness, session-slice
reservations, a 16G swapfile, uid 1000) is tuned for Sleipnir. SL-007
(DEC-028) keeps it as Sleipnir host config, not base; the swapfile moves to
machine config. A second host wanting OOM resilience needs the generic parts
parametrised (sizes, avoid list from the selected desktop), likely alongside
IMP-017's site/host layering. User, 2026-10-16.
