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

## PHASE-03 baseline (EN-1)

Date 2026-10-17; tree HEAD 2eb8db8f8d0ed8cc42c082e0d69c21b64ef7c676 (PHASE-02 committed).
`git status --short -- modules features hosts parked justfile flake.lock`: only ` M justfile` (user
edit; not staged). pi settings.json user edit present, not staged.

| checkout | HEAD | porcelain -uno |
|---|---|---|
| oubliette | 63cc360b9c42aa4e531f4bccd53a46ff48f14eae | clean |
| goad | 250b8ed9cf6f4cda9879fc45b2b3ceb2d52ea987 | clean |
| panopticon | a6648a46e4f8de08f9d841163f1bb30c5750581d | clean |
| satan-patcher | 4efa20542b77d4aad83079da267121a38b08e94f | clean |
| satan-attrd | c8fd7eb51aeada64571270c98f94a30fb7337036 | clean |

(= PHASE-02 table; no drift.)

Evidence (.doctrine/slice/010/evidence/):
- p3-drvs-before.txt 645995ea8e8b36d499b44c1057876893f607ab258b138ef267e6b47ab7ee8191 (= p2 after)
- p3-drvs-sets-before.txt 52d35a0652b852e4b26abca6fc9c14de951c5670c3068f2051eab8be476493ba (= p2 after)
- p3-cov-drvs-before.txt 35b1e0aca1d3686feecdf3a45524ac8c622e0a126c8bc62efb49b81db299624a (8 targets; = p2 after)
- p3-cov-sets-before.txt 933bd38e5a0925b31d3b07980a50828fea7df0eab18fb3887a02d2eec82bb799 (= p2 after)
- p3-opts-before.txt 168c66ae245357662a74e7a5a19fd737ccacdb0924201d3f14d322fc376ff6da (102 lines, 0 ABSENT)
  Script ~/.cache/multihost-gate/p3-opts.sh (outside the tree; same script for after): 34 options x
  {david@Sleipnir, david@Draupnir, home@aarch64-linux}; besides the sheet's list it covers the other
  shells' rendered init (bash.initExtra, nushell.extraConfig/extraEnv, fish.*ShellInit), which yazi's
  integrations also write to. Two script gotchas: string options carry store-path context, so the
  default `--apply` discards it (`builtins.unsafeDiscardStringContext`); and the eval cache returns a
  corrupt "store path … has a name longer than" error for those strings on a second run, so every
  eval uses `--no-eval-cache`.
- probe: ~/.cache/multihost-gate/p3-before/{system,home} (`just probe`, host Sleipnir; `diff -rq`
  against p2-after: identical).

## PHASE-03 result (EX-3) — F-P3-1 resolved (see § F-P3-1 resolution)

Edits B1–B7 done as planned (`git mv` modules/home/zsh.nix → features/terminal/zsh.nix; yazi →
files.manage; nix-search-tv integration → files.search; terminal.zsh record; personal selects it;
zstd moved under `## fileutils` after `xz`). Checkout HEADs/status after: identical to baseline.

| target | drvs | sets | verdict |
|---|---|---|---|
| nixosConfigurations.Sleipnir, darwinConfigurations.Draupnir | identical | equal | identical |
| coverage.Sleipnir+* (6), coverage.base@aarch64-linux | identical | equal | identical |
| packages / legacyPackages / templates | identical | — | identical |
| homeConfigurations.{david,david@Sleipnir} | differs | equal (341) | ordering-only |
| homeConfigurations.david@Draupnir | differs | equal (260) | ordering-only (sets + nix-diff; no probe on Linux) |
| coverage.home@aarch64-linux | differs | 50 → 44 | removals **plus a yazi wrapper rename (F-P3-1)** |

Ordering-only proof (both populated homes). `nix-diff`: every differing drv checked with
`nix derivation show`, store hashes masked, inputDrvs sorted. Masked-identical: activation-script,
hm-putter.json, home-manager-files, hm_.manpath, man-cache (and Draupnir's
hm_LibraryFonts…version). Differing only by permutation: home-manager-path, man-paths (and
Draupnir's home-manager-fonts, home-manager-applications): `__json.chosenOutputs` same multiset,
341/260 entries; david-fish-completions `paths` and home-manager-generation `extraDependencies`:
same tokens. No inputDrv added or removed anywhere; no .zshrc/.zshenv/.zprofile/.zlogin drv in the
diff. Moved entries in home-path (LIS complement): carapace, fzf, atuin (Sleipnir), zoxide, zstd,
gcc-wrapper, zsh, zsh-autocomplete, antidote, eza, lazygit, mcfly.

Built-artefact probe (`~/.cache/multihost-gate/p3-{before,after}`, Sleipnir): system/ `diff -rq`
empty. Home: packages equal sorted; home-path-links **raw-identical** (no collision winner
flipped); home-files-links raw-identical except `.manpath` (the known derived-hash artefact).
Draupnir: the same twelve entries move; Linux shows no winner change for them, but Darwin
contents are unprobed (sets + nix-diff only).

Option spot-checks (`p3-opts-after.txt` vs before): every david@Sleipnir and david@Draupnir line
identical, including `programs.zsh.initContent`, `programs.zsh.{env,profile,login}Extra`,
bash.initExtra, nushell.extraConfig, fish.*ShellInit (init order preserved), yazi
plugins/wrapper/integrations, mcfly flags, nix-search-tv integration true. home@aarch64-linux:
zsh.enable/mcfly.enable/mcfly.fzf.enable → false, zsh options → defaults, initContent loses
initEarly/init/mcfly/yazi fragments, MCFLY_* session vars gone, home.file loses the zsh dotfiles,
yazi.plugins → [], and **yazi.shellWrapperName "y" → "yy"**.

home@aarch64-linux nix-diff: removed antidote, mcfly, mcfly-fzf, zsh, zsh-autocomplete (+ their
fish completions and man paths), hm_.configzsh.{zlogin,zprofile,zshenv,zshrc}, hm_.zshenv,
hm_yaziinit.lua, the eight yazi plugin dirs; `y.fish` → **`yy.fish` (added)**; config.nu changes
`def --env y` → `def --env yy`; config.fish loses mcfly.

**F-P3-1 (STOP, not attributable as removal).** `modules/home/nushell.nix` (home base, outside this
phase's file set; planner's sheet did not list it) also sets `programs.yazi = { enable = true;
enableNushellIntegration = true; }`. So yazi does not leave the base: on a home without
`files.manage` it stays enabled, with HM's stateVersion<26.05 default wrapper `yy` instead of `y`,
no plugins, and HM prints a deprecation warning for the unset `shellWrapperName` on every eval of
that home (seen in `just coverage`). Sleipnir/Draupnir unaffected (files.manage sets "y").
Proposed fix (orchestrator's call): drop the `yazi = {…};` block from modules/home/nushell.nix —
files.manage already sets enable + enableNushellIntegration, so the populated homes should stay
identical and home@aarch64-linux would become removal-only (yazi package too). Needs a re-run of
C2–C5.

Evidence (.doctrine/slice/010/evidence/):
- p3-drvs-after.txt 7d6e7f7bd25d895cc0b18b2402e65a5c3bd1734c1eafedf7d54c2b8bc14e7e75
- p3-drvs-sets-after.txt 52d35a0652b852e4b26abca6fc9c14de951c5670c3068f2051eab8be476493ba (= before)
- p3-cov-drvs-after.txt cb2b33e8812d158ac5ebf2b6706c94d3646567a6b22ca824d7fb41cc8b9a8634 (only home@aarch64-linux differs)
- p3-cov-sets-after.txt b3b2b266ad3e90217b8aa829193cfcbb6cc74a87bd2a634931601166a0075177 (only home@aarch64-linux: 50 → 44)
- p3-opts-after.txt 8827c4d4f595cf513362543504d3dd42363b9f3482d3db60d208ee954b2cc6e9
- nix-diff outputs (scratch, not committed): ~/.cache/multihost-gate/p3-nd-{sleipnir,draupnir,home-aarch64}.txt

### F-P3-1 resolution (2026-10-17)

Orchestrator decision: delete the `yazi = {…};` block from `modules/home/nushell.nix` (files.manage
already sets enable + enableNushellIntegration). C2-C5 re-run against the existing p3-*-before
evidence; the p3-*-after files above were overwritten (the table/hashes above describe the superseded
first run; use these).

| target | verdict |
|---|---|
| systems, Sleipnir+*, base@aarch64-linux, packages/legacyPackages/templates | identical (drvs + sets) |
| homeConfigurations.{david,david@Sleipnir,david@Draupnir} | drv lines and sets (341/341/260) identical to the previous after-state: ordering-only vs before, same proof as above |
| coverage.home@aarch64-linux | **removed-only**, sets 50 -> 43 |

home@aarch64-linux nix-diff (`~/.cache/multihost-gate/p3-nd-home-aarch64.txt`): input drvs removed
only: antidote, mcfly, mcfly-fzf, yazi, zsh, zsh-autocomplete (+ fish completions, man paths),
hm_.configzsh.{zlogin,zprofile,zshenv,zshrc}, hm_.zshenv, hm_yaziinit.lua, the eight yazi plugin
dirs, y.fish (no yy.fish). Nothing added. Rendered nushell/bash/fish init: no added lines vs before.
opts: yazi.enable false, plugins [], zsh/mcfly off, MCFLY_* vars gone; david@Sleipnir/Draupnir
option lines identical to before. Probe (Sleipnir): identical to the previous after-probe; system/
`diff -r` empty vs before; home-files-links differ only in `.manpath`.
The yazi `shellWrapperName` warning is gone (`just coverage`: 0 matches).

Evidence hashes (sha256, overwritten after-files):
- p3-drvs-after.txt 7d6e7f7bd25d895cc0b18b2402e65a5c3bd1734c1eafedf7d54c2b8bc14e7e75
- p3-drvs-sets-after.txt 52d35a0652b852e4b26abca6fc9c14de951c5670c3068f2051eab8be476493ba
- p3-cov-drvs-after.txt caa83df8ebc006bc72ce05060ec63df4e69cfee10c78cb6a2b49bcfbe4f3b5fd
- p3-cov-sets-after.txt 9ab9f5246e2601fac02445812fdd122d927c8a81e34c97c49902dfcf2d33f372
- p3-opts-after.txt 6174e4c680efc8f70857c051b6b5b50d974b480f92ea014149ba2beaf9e8c555

Gates after the fix: `just test` green; `just coverage` green, no shellWrapperName warning;
`nix fmt` on modules/home/nushell.nix: 0 changed. **flake.lock drift**: the emacs-overlay entry moved
(lastModified 1792095206 -> 1792158883, rev 3d05567b -> e87b60e7) at 02:56 during the re-run, from an
eval/test command re-resolving it (known mem.fact.flakes.fmt-relock risk); not reverted (no
checkout/restore). Evidence did not change with it. Orchestrator: do not commit flake.lock.

## PHASE-03 gates

- `just test`: green. `just coverage` (incl. isolation: home@aarch64-linux, david@Draupnir ok): green,
  with the new yazi `shellWrapperName` warning from home@aarch64-linux (F-P3-1).
- `nix fmt --no-write-lock-file -- --no-cache` on the 7 touched nix files: 1 changed
  (modules/home/programs.nix `{...}:` → `_:`); `just drvs` re-taken after: unchanged.
- `git diff --stat -- flake.lock`: empty.
- VT-1 (4 keywords), VT-2 (3), VT-3 (1): each present once. `grep -c 'yazi\|nix-search-tv'
  modules/home/programs.nix` = 0; modules/home/zsh.nix gone; features/terminal/zsh.nix tracked;
  `grep zsh modules/home/{cli,default}.nix`: none. Stale-reference grep: no hits.

## PHASE-04 baseline (EN-1)

Date 2026-10-17; tree HEAD a7b67202957078faa5c2bc467e6a46c151c698b7 (PHASE-03 committed).
`git status --short -- modules features hosts parked justfile flake.lock .doctrine/slice/010`:
` M justfile` (user), ` M flake.lock` (pre-existing emacs-overlay drift from PHASE-03's re-run:
lastModified 1792095206 -> 1792158883, rev 3d05567b -> e87b60e7; `git diff -- flake.lock | sha256sum`
= 2fc8da01c950964c5bbc9e55c4685474cddedd9742b93cb3ad30544e46959130), ` M .doctrine/slice/010/slice-010.toml`
(orchestrator). pi settings.json user edit present. None staged.

| checkout | HEAD | porcelain -uno |
|---|---|---|
| oubliette | 63cc360b9c42aa4e531f4bccd53a46ff48f14eae | clean |
| goad | 250b8ed9cf6f4cda9879fc45b2b3ceb2d52ea987 | clean |
| panopticon | a6648a46e4f8de08f9d841163f1bb30c5750581d | clean |
| satan-patcher | 4efa20542b77d4aad83079da267121a38b08e94f | clean |
| satan-attrd | c8fd7eb51aeada64571270c98f94a30fb7337036 | clean |

(= PHASE-03 table; no drift.)

Evidence (.doctrine/slice/010/evidence/):
- p4-drvs-before.txt 7d6e7f7bd25d895cc0b18b2402e65a5c3bd1734c1eafedf7d54c2b8bc14e7e75 (13 lines; = p3 after)
- p4-drvs-sets-before.txt 52d35a0652b852e4b26abca6fc9c14de951c5670c3068f2051eab8be476493ba (= p3 after)
- p4-cov-drvs-before.txt caa83df8ebc006bc72ce05060ec63df4e69cfee10c78cb6a2b49bcfbe4f3b5fd (8 targets; = p3 after)
- p4-cov-sets-before.txt 9ab9f5246e2601fac02445812fdd122d927c8a81e34c97c49902dfcf2d33f372 (= p3 after)
- p4-opts-before.txt e5315f1831dfc25eda3e1c59cec38500c9cf65c331c0c1a34037fe93c0423ef8 (59 lines, 0 ABSENT)
  Script ~/.cache/multihost-gate/p4-opts.sh (outside the tree; same script for after), p3-opts.sh's
  skeleton (`--no-eval-cache`, context-discarding apply). Systems (Sleipnir, base@aarch64-linux):
  root/david shell (+ assigner/postgres on Sleipnir), defaultUserShell, programs.zsh.{enable,
  enableCompletion,*Init}, pathsToLink (/share/zsh count + full list), environment.shells,
  environment.etc names, default/useradd source drv, systemPackages counts by pname for zsh,
  bash-interactive, nix-zsh-completions, nushell. Homes (david@Sleipnir, david@Draupnir,
  home@aarch64-linux): systemd.user.enable, systemd.user.services names, xdg.configFile names,
  home.packages counts for zmx/shpool, services.emacs.enable, programs.zsh.enable.
  Baseline values of note: Sleipnir systemPackages zsh x5 (sheet guessed 4), bash-interactive x1;
  base zsh x3; /share/zsh x3 in pathsToLink on both; root/assigner/postgres shell zsh.
- probe: ~/.cache/multihost-gate/p4-before/{system,home} (`just probe`, host Sleipnir; `diff -rq`
  against p3-after: identical).

## PHASE-04 result (EX-3)

Edits B1–B5 as planned, B1–B3 in one edit set: `terminal.zsh` gains `nixos = _: { programs.zsh.enable
= true; environment.pathsToLink = ["/share/zsh"]; }` (record comment rewritten);
`modules/nixos/programs.nix` loses `zsh.enable` and `pathsToLink`; `modules/nixos/env.nix` loses its
`pathsToLink`; `modules/nixos/user.nix` loses `defaultUserShell` (refactor: the remaining one-key
`users = { mutableUsers = true; }` block collapsed to `users.mutableUsers = true;`, DEC-042 comment);
`git mv modules/home/shpool.nix parked/shpool.nix` + `# parked (DEC-043)…` header, dropped from
`modules/home/default.nix`; `features/editor/emacs.nix` lists `zmx # session restore (IMP-001)`.
B7 smoke evals (Sleipnir, base@aarch64-linux, Draupnir system, david@Draupnir) passed first time.

Checkout HEADs/status after: identical to baseline. `git diff -- flake.lock | sha256sum` after:
2fc8da01… (unchanged; no further emacs-overlay move this phase).

| target | drvs | sets | verdict |
|---|---|---|---|
| nixosConfigurations.Sleipnir | differs | 565 → 565: `zsh-5.9.2` −4, `bash-interactive-5.3p15` +4 | attributed (root/assigner/postgres shell, useradd SHELL, pathsToLink) |
| coverage.Sleipnir+{llama-cpp,openrgb,podman,rocm,speech,sunshine} | differ | counts unchanged; same −4/+4 each | attributed; same 15 differing drvs and identical masked env diffs as Sleipnir |
| coverage.base@aarch64-linux | differs | 184 → 182: `zsh` −3, `nix-zsh-completions` −1, `bash-interactive` +2 | attributed (zsh removed, root bash) |
| homeConfigurations.{david,david@Sleipnir} | differ | 341 → 342: `zmx-0.8.1` +1 | attributed (zmx duplicate; shpool unit gone) |
| homeConfigurations.david@Draupnir | differs | 260 → 261: `zmx-0.8.1` +1 | attributed (zmx duplicate only; sets + nix-diff, no probe on Linux) |
| coverage.home@aarch64-linux | differs | equal (43) | attributed (shpool unit gone) |
| darwinConfigurations.Draupnir, packages, legacyPackages, templates | identical | equal | identical |

Multiset method: `p4-names.sh before|after` (`~/.cache/multihost-gate/`) evaluates
`map (p: p.name)` per target, before from `git+file:///home/david?dir=flakes&rev=a7b67202…` with the
same overrides; every before eval reproduced its p4-*-before set hash exactly. n = m = 4 on Sleipnir
and all six Sleipnir+* (zsh x5 → x1: shadow's defaultUserShell + root/assigner/postgres shells; zsh x1
left from programs.zsh). Both homes: the added element is zmx's existing drvPath (Sleipnir
`05n47w04…-zmx-0.8.1.drv` x2, Draupnir `mzlwny0h…-zmx-0.8.1.drv` x2).

nix-diff (`~/.cache/multihost-gate/p4-nd-<target>.txt`), every differing drv's env compared with store
hashes masked and `__json` expanded (`p4-envdiff.py`; summaries `p4-env-<target>.txt`):
- **Sleipnir and Sleipnir+* (15 drvs)**: `system-path` chosenOutputs zsh x4 → bash-interactive x4,
  pathsToLink one `/share/zsh` fewer; `user-environment` same pathsToLink change; `useradd`
  `SHELL=/run/current-system/sw/bin/zsh` → `…/bash`; `users-groups.json` (`p4-usersdiff.py`, per
  field): exactly `users.{root,assigner,postgres}.shell` `/run/current-system/sw/bin/zsh` → `…/bash`.
  Masked-identical: activate, dry-activate, etc, dbus-1, system-units, user-units, the
  accounts-daemon/dbus-broker/polkit units and restart triggers (downstream of system-path).
  **No `etc-zshrc`/`zshenv`/`zprofile`/`zinputrc`/`etc-shells` drv differs**: /etc/zsh* text identical.
- **base@aarch64-linux**: `etc` loses `zinputrc zprofile zshenv zshrc` entries and their drvs;
  `etc-shells` loses the two zsh lines; `system-path` loses zsh x3, nix-zsh-completions, all three
  `/share/zsh`, gains bash-interactive x2; `user-environment` pathsToLink −3 `/share/zsh`; useradd
  SHELL → bash; users-groups.json: only `users.root.shell` → bash. Nothing added beyond bash.
- **david@Sleipnir**: home-manager-path and man-paths +zmx chosenOutput; david-fish-completions
  +`zmx-0.8.1-fish-completions` token; home-manager-files and hm-putter.json lose exactly
  `.config/systemd/user/shpool.service` and `…/default.target.wants/shpool.service`
  (and the `shpool.service` input drv). activation-script, hm_.manpath, man-cache masked-identical.
- **david@Draupnir**: +zmx chosenOutput in home-manager-path, man-paths, home-manager-fonts,
  home-manager-applications (all buildEnvs over home.packages); +zmx fish-completions token.
  home-manager-files and hm-putter.json masked-identical (shpool was inert: systemd.user off).
- **home@aarch64-linux**: home-manager-files and hm-putter.json lose the two shpool entries only.

Built-artefact probe (Sleipnir; `~/.cache/multihost-gate/p4-{before,after}`): system/ `diff -rq`
**empty** (system-path-links raw-identical: no collision winner flipped). Home: packages equal (the
probe dedupes, so the zmx duplicate is invisible), home-path-links raw-identical, home-files-links
lose the two shpool entries; `.manpath` hash otherwise. Draupnir: no probe (Darwin); proof is
sets + nix-diff above.

Option check (`p4-opts-after.txt` vs before; list lines compared element-wise):
```
nixosConfigurations.Sleipnir users.users.root.shell = "zsh" -> "bash-interactive"
nixosConfigurations.Sleipnir users.users.david.shell = "nushell" (unchanged)
nixosConfigurations.Sleipnir programs.zsh.enable = true (unchanged; now via terminal.zsh)
coverage."base@aarch64-linux" users.users.root.shell = "zsh" -> "bash-interactive"
coverage."base@aarch64-linux" users.users.david.shell = "nushell" (unchanged)
coverage."base@aarch64-linux" programs.zsh.enable = true -> false
```
Sleipnir: defaultUserShell zsh → bash-interactive; zsh enableCompletion/shellInit/
interactiveShellInit/promptInit/loginShellInit identical; pathsToLink zcount 3 → 2 (one element
removed, nothing else); environment.shells and etc names unchanged; useradd drv changed;
systemPackages zsh 5 → 1, bash-interactive 1 → 5. base: zcount 3 → 0; shells lose the two zsh
entries; etc names lose zinputrc/zprofile/zshenv/zshrc only; zsh 3 → 0, nix-zsh-completions 1 → 0,
bash-interactive 1 → 3. Homes: systemd.user.services lose `shpool` only (all three; Draupnir's
`systemd.user.enable` stays false); xdg.configFile loses the two shpool unit names on Sleipnir and
home@aarch64-linux only; zmx count 1 → 2 (Sleipnir, Draupnir), 0 → 0 (home@aarch64-linux);
services.emacs.enable and programs.zsh.enable unchanged.

**S1 (expected, attributed; orchestrator decision).** `users.users.assigner.shell` and
`users.users.postgres.shell` move zsh → bash-interactive with root's, via `useDefaultShell` picking
up NixOS's default (`programs/bash/bash.nix` `mkDefault pkgs.bashInteractive`). Within DEC-042's
intent (the base no longer picks a shell); not set explicitly. Evidence: opts lines 3–4,
users-groups.json field diff above.

**Attributed deviations from EX-3's wording** (orchestrator decision: plan.toml unchanged):
- `coverage.home@aarch64-linux` also differs (shpool is in the home base and the unit renders on
  Linux): shpool unit + wants link removed, sets equal. Not in EX-3's target list; expected.
- The zmx change is a **duplicate entry**, not an ordering change: home sets +1 (341 → 342,
  260 → 261), the added element zmx's existing drvPath; built home-path links identical.
- Systems' package *sets* change by design (zsh/bash-interactive multiset, above).

Evidence (.doctrine/slice/010/evidence/):
- p4-drvs-after.txt 26f923b32957061aa6849b44086e0e3ca2c0796d09a86154f974e23a3df13e64
- p4-drvs-sets-after.txt 0fbe608cb4ea32df204267052a609f97cd55db0f3ae2928c7251eef737132b5b
- p4-cov-drvs-after.txt eca95151f5fffce5ec724bbfdbb960faee180b8ed8ce5435d975b8942be12fa0
- p4-cov-sets-after.txt 8bbfc1f12a3e7484a201ad10cedde5c0ff8ba7f12357faf7d19f7006577fd5a0
- p4-opts-after.txt b4cf960eedc4c9e36c0f5925b1958df716495505d8a2324d549520586fa03140
- scratch (not committed): ~/.cache/multihost-gate/p4-{names.sh,envdiff.py,usersdiff.py,tokdiff.py},
  p4-names/, p4-nd-*.txt, p4-env-*.txt

## PHASE-04 gates

- `just test`: green. `just coverage`: green, isolation ok for home@aarch64-linux and david@Draupnir;
  0 `evaluation warning` lines (PHASE-03: 0).
- `nix fmt --no-write-lock-file -- --no-cache` on the 7 touched nix files: 0 changed (run after the
  edits and again at the end).
- flake.lock: `git diff -- flake.lock | sha256sum` 2fc8da01… before and after; the pre-existing
  emacs-overlay drift (e87b60e7) is unchanged and not this phase's. Do not commit it.
- TDD: before edits VT-1 `programs.zsh.enable = true` 0 (red), `/share/zsh` 1 (already satisfied by
  the old record comment, so that keyword alone could not go red), VT-2 `zmx` 0 (red). After: 1, 2, 1.
- VA-1: `grep -c defaultUserShell modules/nixos/user.nix` = 0; `git ls-files parked/shpool.nix`
  lists it; `grep -c shpool modules/home/default.nix` = 0; drvs attribution: § PHASE-04 result.
  Greps: no `defaultUserShell` in any .nix; `shpool` only in parked/shpool.nix, the
  `features/terminal.nix` `# shpool # vs abduco` comment and review.features.local.md; `zsh` in
  modules/nixos/*.nix only user.nix's `#shell = pkgs.zsh;` comment.
- **VH-1 pending** (user, after the next `system-switch` + `home-switch`; not run, not marked):
  `sudo -i` gives bash (`echo $0`; `getent passwd root` ends `/run/current-system/sw/bin/bash`);
  the user's login is still nu (`getent passwd david`); zsh still starts with its config (`zsh -i`,
  completions, mcfly); emacs session restore via zmx works; `systemctl --user status shpool` no
  longer exists. `mutableUsers = true`: if root is still zsh after the switch, look at
  update-users-groups first.
- Changed paths: R `modules/home/shpool.nix` → `parked/shpool.nix` (staged by git mv, header edit
  unstaged); M `modules/nixos/{user,programs,env}.nix`, `modules/home/default.nix`,
  `features/terminal.nix`, `features/editor/emacs.nix`, `.doctrine/slice/010/notes.md`;
  new untracked `.doctrine/slice/010/evidence/p4-*.txt` (10).

## PHASE-05 result

Docs and governance only; no `.nix` edits. Model: sonnet (bounded prose and CLI edits).

- README.md: feature-tree listing (`sandbox`, `avahi`, `ssh`, `locate`, `tailscale`, `zsh`, `terminal/zsh.nix`
  row); § Parked rewritten (`parked/`, DEC-043, ADR-005; hyprland/kmscon do not evaluate; shpool evaluates but
  is unused; danksearch gone); § Hosts states the reduced NixOS and home bases and names the records that took
  over, with the no-sshd warning (DEC-044); § Printing cites `services.avahi`.
- `.doctrine/rfc/001/rfc-001.md` (direct edit): SL-010 bullet in Where things stand, Target shape (`parked/`
  row; `ssh` dropped from the base bullet), W7 (headless selects `services.ssh`, probably `files.locate`), W9
  (base tidy done), References (DEC-042..044). Status and toml untouched.
- DEC-027 and DEC-031: one SL-010 consequence each via `doctrine knowledge edit decision --consequences`;
  `doctrine show` confirms 3 items each, intact. `doctrine validate`: corpus clean.
- VT-1 (README grep counts): before all 0; after parked/ 2, services.avahi 2, terminal.zsh 2, net.tailscale 1,
  files.locate 1, services.ssh 2, virt.sandbox 1. (`verify-vt` is UNATTRIBUTABLE per ISS-005; judged by grep.)
- EX-3 stale-reference grep: prints nothing (before: README.md:343, 344, 555).
- Deviation (EX-1, orchestrator decision): README does not claim a "commented danksearch input"; the input and
  module are both gone (removed in `07c4998e`), so README says so in one clause.
- `git diff -- flake.lock | sha256sum` = `2fc8da01c950964c5bbc9e55c4685474cddedd9742b93cb3ad30544e46959130`
  (unchanged). Header comments of `modules/{nixos,home}/default.nix` left alone (F-plan-2). Research restamp
  and IMP-001 closure not touched.
