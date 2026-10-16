# Notes SL-010: Base tidy: optional pieces out of modules/ (RFC-001 W9)

Durable per-slice scratchpad — tracked in git. The place to lift anything from a
disposable phase sheet (`.doctrine/state/.../phase-NN.md`) that must survive
`rm -rf` before the slice close-out audit harvests it.

## Harvest
<!-- single-copy: updated in place each harvest; ids only, never restated content -->
fresh-as-of: 2026-10-17 · ready (pre-PHASE-01) · 6f4b21c0

### Produced
- DEC-042, DEC-043, DEC-044 (accepted; shape SL-010)
- RV-022 (design review pass; adversarial lane waived)
- design.md (locked r32), plan.toml PHASE-01..05

### Learned
- HM tailscale-systray is PartOf/WantedBy graphical-session.target (inert headless)
- Draupnir logs straight into nu (user chsh'd); darwin layer PATH block is live

### Open
- IMP-001 closes with PHASE-04
- PHASE-04 VH-1 (user, after switch)

## Design triage (2026-10-17)

Source: research/research.md (threads 1–2, X1–X5, D-a..D-f).

**Settled by the user (2026-10-17):** option 1 (optional pieces only; base
stays); parked modules move to `parked/` at the flake root, incl. shpool
(IMP-001); OQ-1 cli.nix split as proposed; OQ-2 avahi feature required by
`services.printing`; OQ-4 nix-ld stays base. darwin/ out of scope.

**Open shaping questions** (design inquiries):
- system packages → nixos halves of existing features vs home packages (X1)
- tailscale tray placement once tailscale leaves the base (X2)
- rust-motd and root's helix: stay base? (D-d)
- name/selection of the sandbox record (bubblewrap, distrobox)
- sysprof placement; nix-search-tv option placement (X4)
- one DEC amending DEC-027 + DEC-031 (D-f)

**Risks:** drv identity (ordering diffs need proof); Sleipnir must select
avahi explicitly (requires never auto-selects); dns.nix depends on avahi.

**Assumptions:** HM's tailscale-systray unit is bound to the graphical
session, so it is inert headless (verify in design).

**Constraining governance:** DEC-027, DEC-031, ADR-001 D4, ADR-002, ADR-005,
DEC-030; RFC-001 working rules.

## PHASE-01 baseline (EN-2)

Date 2026-10-17; tree HEAD 18f3142c5b1aca3762a345f70b0c433b7eafbce0.
justfile/pi settings.json user edits present, not staged.

| checkout | HEAD | porcelain -uno |
|---|---|---|
| oubliette | 63cc360b9c42aa4e531f4bccd53a46ff48f14eae | clean |
| goad | 250b8ed9cf6f4cda9879fc45b2b3ceb2d52ea987 | clean |
| panopticon | a6648a46e4f8de08f9d841163f1bb30c5750581d | clean |
| satan-patcher | 4efa20542b77d4aad83079da267121a38b08e94f | clean |
| satan-attrd | c8fd7eb51aeada64571270c98f94a30fb7337036 | clean |

Evidence:
- .doctrine/slice/010/evidence/p1-drvs-before.txt sha256 6fd1affde81c482449cc094a02c3e1d8f230c7e1ee3334d7501e7c53d5124175
- .doctrine/slice/010/evidence/p1-drvs-sets-before.txt sha256 52d35a0652b852e4b26abca6fc9c14de951c5670c3068f2051eab8be476493ba

## PHASE-01 result

- Checkout HEADs/status after: identical to baseline.
- drvs diff: empty (sha256 6fd1affd... identical). drvs-sets diff: empty (52d35a06... identical). Evidence: evidence/p1-drvs-after.txt, p1-drvs-sets-after.txt.
- just test: green. just coverage (incl. isolation): green. flake.lock: no diff.
- VA-1: modules/home/linux holds only default.nix; modules/nixos has no hyprland/kmscon; modules/treefmt.nix.txt absent; git ls-files parked = hyprland.nix, kmscon.nix. Stale-reference grep (non-.doctrine): empty.
- Changed paths: R modules/nixos/{hyprland,kmscon}.nix -> parked/; D modules/home/linux/{helix,slk,bough}.nix, modules/treefmt.nix.txt; M modules/home/linux/default.nix, hosts/Sleipnir/config.nix, .doctrine/slice/010/notes.md; optional evidence/p1-*.txt.

## PHASE-02 baseline (EN-1)

Date 2026-10-17; tree HEAD 6cf150c554cf0eb41f8ebc40ab9d99e4f4262f0d (PHASE-01 committed).
`git status --short -- modules features hosts parked justfile flake.lock`: only ` M justfile` (user edit,
push-local recipe; not staged). pi settings.json user edit present, not staged.

| checkout | HEAD | porcelain -uno |
|---|---|---|
| oubliette | 63cc360b9c42aa4e531f4bccd53a46ff48f14eae | clean |
| goad | 250b8ed9cf6f4cda9879fc45b2b3ceb2d52ea987 | clean |
| panopticon | a6648a46e4f8de08f9d841163f1bb30c5750581d | clean |
| satan-patcher | 4efa20542b77d4aad83079da267121a38b08e94f | clean |
| satan-attrd | c8fd7eb51aeada64571270c98f94a30fb7337036 | clean |

Evidence (.doctrine/slice/010/evidence/):
- p2-drvs-before.txt sha256 6fd1affde81c482449cc094a02c3e1d8f230c7e1ee3334d7501e7c53d5124175 (= p1 after)
- p2-drvs-sets-before.txt sha256 52d35a0652b852e4b26abca6fc9c14de951c5670c3068f2051eab8be476493ba (= p1 after)
- p2-cov-drvs-before.txt sha256 06c9913fed34287e6933c6eaf28020566a9bf93af03dfc79ff814cc6fcd6b278 (8 targets)
- p2-cov-sets-before.txt sha256 94efb1a6478543f19faa163124f7c308363c16ad303cd9ece482069eda1cca35
- p2-opts-before.txt sha256 51f2a1c4776c11c5c2d62d72b7edb67262f951679720f3cd498719cfdf742f0a
  (script ~/.cache/multihost-gate/p2-opts.sh, outside the tree; same script for after)
- probe: ~/.cache/multihost-gate/p2-before/{system,home} (`just probe`, host Sleipnir)

## PHASE-02 result (EX-5)

Checkout HEADs/status after: identical to the baseline table (no drift).
`flake.lock`: no diff. `nix fmt --no-write-lock-file -- --no-cache` on the 16 touched files: 0 changed.

| target | drvs | sets | verdict |
|---|---|---|---|
| nixosConfigurations.Sleipnir | differs | equal (565) | ordering-only |
| coverage.Sleipnir+{llama-cpp,openrgb,podman,rocm,speech,sunshine} | differ | equal | ordering-only |
| homeConfigurations.{david,david@Sleipnir} | identical | equal | identical (tray move changes no drv) |
| homeConfigurations.david@Draupnir, darwinConfigurations.Draupnir | identical | equal | identical |
| packages / legacyPackages / templates | identical | — | identical |
| coverage.home@aarch64-linux | identical | equal | identical |
| coverage.base@aarch64-linux | differs | 215 → 184 | removed-only (below) |

Ordering-only proof (Sleipnir + all six Sleipnir+*): `nix-diff before after` has exactly one
environment mismatch, in `system-path`; every other differing drv (activate, etc, dbus-1,
system-units, user-units, unit-{accounts-daemon,dbus-broker,polkit}.service, X-Restart-Triggers-*)
is "input derivations differ but have already been compared" (downstream of system-path). In
system-path's `__json` the only differing field is `chosenOutputs`, equal as a sorted list
(565/566/569/565/568/568 entries). No firewall, unit, or /etc content change.

Built-artefact probe (`~/.cache/multihost-gate/p2-{before,after}`, Sleipnir): `diff -rq` of
system/ empty — incl. `system-path-links` (no collision winner flipped), ports, groups,
kernelParams, root-options, udev-rules, session-desktops, fontconfig. Home: packages,
home-path-links, home-files-links raw-identical (no masking needed).

Option spot-checks (`p2-opts-after.txt` vs before): every nixosConfigurations.Sleipnir and
homeConfigurations line identical (avahi/openssh/tailscale/locate/udisks2/sysprof/_1password/
fail2ban enables, openssh settings, locate prunePaths/interval, allowedTCPPorts
[22,80,443,27015,27036,27037,27040], UDP ports, etc/services/timers/wrappers name sets, root
shell; tray true on david@Sleipnir, false on Draupnir). Diffs only on base@aarch64-linux:
avahi/openssh/fail2ban/tailscale/locate/udisks2/sysprof/_1password → false, locate.interval →
default "02:15", openssh.settings → defaults, TCP [22] → [], UDP [5353] → [], etc/services/timers/
wrappers sets shrink.

base@aarch64-linux nix-diff (removed-only): input-name sets lose 1password-cli, avahi,
bubblewrap, cargo, cargo-update, distrobox, distrobox-tui, fail2ban (+ fail2ban.local, jail.local,
paths-nixos.conf), glib, glibc-iconv, icu4c, iptraf-ng, libblockdev, libffi, libyaml, nethogs,
nmon, nss-mdns, openssh (+ check-sshd-config, sshd.conf-final, ssh-root-provision.conf), openssl,
plocate (+ etc-updatedb.conf), security-wrapper-{op,plocate}, sysprof, tailscale, udisks
(+ udisks2.conf), unit-{avahi-daemon.*,fail2ban.*,sshd*,tailscaled,update-locatedb.*}, valgrind,
vnstat, ydotool, zlib; nothing added. Content changes in shared drvs, each a consequence of a
removal, checked against HEAD (`git+file:…?dir=flakes&rev=6cf150c5`): users lose avahi, sshd;
groups lose avahi, fail2ban, onepassword-cli, plocate, sshd; services/sockets/timers lose only the
units above; udev/dbus packages lose udisks/avahi/sysprof; tmpfiles lose avahi/udisks2 dirs;
nsswitch drops `mdns4_minimal [NOTFOUND=return]`; nftables input-allow drops tcp 22 / udp 5353;
system.conf ManagerEnvironment PATH and nscd/timesyncd LD_LIBRARY_PATH drop openssh / nss-mdns;
etc loses fail2ban/*, libblockdev/*, ssh/sshd_config, udisks2/udisks2.conf, updatedb.conf.
One non-obvious item: `pam.d/sshd` remains (NixOS always defines it) but, with openssh off, falls
back to defaults — gains `auth sufficient pam_unix.so` and loses the loginuid/systemd session
lines. Inert without an sshd daemon; all other PAM services' text identical.

Evidence (.doctrine/slice/010/evidence/):
- p2-drvs-after.txt 645995ea8e8b36d499b44c1057876893f607ab258b138ef267e6b47ab7ee8191
- p2-drvs-sets-after.txt 52d35a0652b852e4b26abca6fc9c14de951c5670c3068f2051eab8be476493ba (= before)
- p2-cov-drvs-after.txt 35b1e0aca1d3686feecdf3a45524ac8c622e0a126c8bc62efb49b81db299624a
- p2-cov-sets-after.txt 933bd38e5a0925b31d3b07980a50828fea7df0eab18fb3887a02d2eec82bb799 (only base line differs)
- p2-opts-after.txt 71f7d7b456e62a61e8d164f01ca0f426c1fb0f88934b09f35017b7d7dbc16f2c

## PHASE-02 gates

- `just test`: green. `just coverage` (incl. isolation: home@aarch64-linux, david@Draupnir ok): green.
- `just gate` (test + sandboxed treefmt check): green, 0 changed.
- `git diff --stat -- flake.lock`: empty.
- VT-1..VT-6 keywords each present once; `grep tailscale-systray features/desktop/core/home.nix`: none (VA-1).
- Stale-reference grep: only README l.555 (`modules/nixos/avahi.nix`), left for PHASE-05.
- Changed paths: D (git rm, staged) modules/nixos/{lib,cargo,util,avahi,ssh,locate}.nix;
  M modules/nixos/{default,cli,programs,network}.nix, features/{dev,net,files,security,services,virt}.nix,
  features/desktop/core/{gui,home}.nix, features/profiles/{workstation,personal-linux}.nix,
  hosts/Sleipnir/{features,dns}.nix, .doctrine/slice/010/notes.md;
  A (untracked) .doctrine/slice/010/evidence/p2-*.txt (10 files).
