<!-- doctrine:section sec-1 -->
## Shape

Six legacy flags are retired. Two become Sleipnir machine config (DEC-019), four become tree features (DEC-020, DEC-021). One unconditional module, podman, becomes a fifth feature that Sleipnir does not select (DEC-022).

```
legacy flag            becomes                                  selected by
hardware.microcode  ─> hosts/Sleipnir/machine.nix               (unconditional import)
hardware.ssd        ─> hosts/Sleipnir/machine.nix               (unconditional import)
virt.qemu           ─> features/virt.nix  qemu                  hosts/Sleipnir/features.nix (host property)
virt.docker         ─> features/virt.nix  docker                profiles/workstation.nix (mkDefault)
apps.appimage       ─> features/non-nix-packages.nix appimage   profiles/workstation.nix (mkDefault)
apps.flatpak        ─> features/non-nix-packages.nix flatpak    profiles/workstation.nix (mkDefault)
apps.cad            ─  unchanged, legacy flag (IMP-016)
(podman.nix, no flag) ─> features/virt.nix  podman              nobody; coverage target Sleipnir+podman
```

- Each feature owns everything it switches: its group, if it needs one (IMP-003), and its packages (the unconditional duplicates go).
- Sleipnir's effective configuration is unchanged (ADR-001 D7), except one intended change: podman is removed (DEC-022). The only drv diffs allowed are the ones listed under Verification, each proven.
- One commit per flag group, in the order hardware, virt, podman, apps; the podman commit holds the only intended behaviour change. Each commit changes the flag declaration, the host's setting and the import gate together: the resolver refuses a flag at a feature's path (`features.nix:127-128`), and an undeclared or missing flag fails evaluation.
<!-- doctrine:section sec-2 -->
## Sleipnir machine config (DEC-019)

New hand-written `hosts/Sleipnir/machine.nix`, imported by `hosts/Sleipnir/config.nix` immediately after `./hardware-configuration.nix`. It holds what this host physically (or, for a VM, virtually) is: config bound to its parts.

```
hosts/Sleipnir/
  meta.nix                     what kind of host (data)
  config.nix                   entry point
  features.nix                 what it selects
  machine.nix                  what it physically is (hand-written)
  hardware-configuration.nix   what nixos-generate-config detected (generated)
```

- Header comment: hand-written config bound to this machine's parts; `hardware-configuration.nix` beside it is generated (`just regenerate-hardware`) and must not be edited; generic hardware support that any host may select is a feature (`features/hardware.nix`), not machine config.
- Body: the content of `modules/nixos/microcode.nix` (the `inputs.ucodenix.nixosModules.default` import, `boot.kernelParams = ["microcode.amd_sha_check=off"]`, `services.ucodenix` with the 9950X `cpuModelId`) and of `modules/nixos/ssd.nix` (`fileSystems."/".options`), merged into one module with its `{inputs, ...}` argument. `microcode.amd_sha_check=off` stays with ucodenix: ucodenix asks for it (its README §3) and warns without it.
- `boot.shell_on_fail` is a generic boot-rescue param, not bound to the machine's parts. It moves to `modules/nixos/boot.nix` as `boot.kernelParams`.
- `modules/nixos/{microcode,ssd}.nix` are deleted (`git rm`).
- `inputs` already reaches `config.nix` and its imports as a specialArg (`hosts.nix:65-68`).
- Order: `fileSystems."/".options` has no other definer, so it is order-free. `boot.kernelParams` is also set by `radeon.nix:10`, so the kernel command line order may change. The params are independent; the sorted compare proves the set (see Verification).
<!-- doctrine:section sec-3 -->
## virt: qemu, docker and podman

Three inline records appended to `features/virt.nix` after `capsule`, in the order `qemu`, `docker`, `podman`. Each `nixos` half is the body of its module file, moved verbatim except as noted. `modules/nixos/{qemu,docker,podman}.nix` are deleted.

- **qemu** (`nixos = {pkgs, username, lib, ...}:`): quickemu and qemu_kvm, libvirtd with `qemu.package = pkgs.qemu_kvm`, the virbr0 firewall ports, `users.groups.libvirtd.members = [username]`, virt-manager, and the `mkForce []` on the libvirtd and libvirt-guests `wantedBy`. Comments move with their lines.
- **docker** (`nixos = {pkgs, config, ...}:`): docker, docker-compose and lazydocker; `virtualisation.containers.enable`; rootless docker with its DNS settings; `virtualisation.docker.enable = false` with its comment. No group: the rootless daemon serves a per-user socket, and nixpkgs creates the `docker` group only when the rootful daemon is enabled (`nixos/modules/virtualisation/docker.nix:267,280`). The `extraGroups = ["docker"]` in `docker.nix` is dropped, not moved.
- **podman** (`nixos = {pkgs, username, ...}:`): podman, podman-compose, podman-desktop, podman-tui, distrobox and crun; `virtualisation.containers.enable`; podman with `dockerCompat` and the DNS network setting; `users.users.${username}.extraGroups = ["podman"]` (the group exists when podman is enabled). distrobox is also in `modules/shared/cli/_packages/dev.nix:34`, which reaches both home and system-path (through `modules/nixos/cli.nix`), so it stays on Sleipnir in both and runs on docker.
- **docker and podman are exclusive (DEC-022).** Both ship `bin/docker` (podman through `dockerCompat`), and NixOS's system-path silently keeps whichever is listed first (`pkgs/build-support/buildenv/builder.pl:200-202`). The `docker` feature asserts `!config.virtualisation.podman.enable`, with a message naming both features and IMP-018. It tests the NixOS option, not the feature, so it also catches podman switched on by any other module. The assertion lands in the podman commit, not the virt commit: until then `podman.nix` is still unconditional, so the virt commit would fail.

```
                  today                                   after
bin/docker        docker (pos 71) beats podman shim       docker only
                  (pos 334): by list position             podman + docker selected → build fails
podman            unconditional (podman.nix)              virt.podman, unselected; Sleipnir+podman coverage
```
- **Groups (IMP-003).** `docker` and `libvirtd` are removed from `user.nix:15`. qemu provides libvirtd through `users.groups.libvirtd.members`; deselecting qemu removes it. The `docker` entry named a group that does not exist on Sleipnir, so dropping it changes no effective membership. `podman` moves with its feature, so Sleipnir loses it.
- **Rootful docker is refused, everywhere.** `modules/nixos/security.nix` (unconditional) asserts `!config.virtualisation.docker.enable`, with a message that docker on this flake is rootless only. It lives outside the feature so it holds whether or not `virt.docker` is selected, and catches a `mkForce true` that the feature's plain `false` would not.
- **Podman's storage is left alone.** `~/.local/share/containers` (6.5 GB on 2026-10-15 after pruning, including the `supabase_*_satan` stack and podman's `archlinux` and `chimera` boxes) stays on disk, unreachable until `virt.podman` is selected again. Nothing in this slice deletes it.
<!-- doctrine:section sec-4 -->
## non-nix-packages: appimage and flatpak (DEC-020)

New area file `features/non-nix-packages.nix` with a header comment ("package management outside Nix"; shape: README § Feature tree) and two inline records:

- **appimage**: `nixos = _: { programs.appimage = { enable = true; binfmt = true; }; }`.
- **flatpak**: `nixos = _: { services.flatpak.enable = true; }`.

`features/default.nix` gains `{ name = "non-nix-packages"; value = import ./non-nix-packages.nix; }` after `virt`: appended, so existing projection order is unchanged (ADR-002 D5). The file needs `git add -N` before evaluation (`mem.fact.flakes.git-add-n`).

**Duplicates removed**, so each feature is the only switch:
- `modules/nixos/programs.nix:157-158`: `appimage.binfmt` and `appimage.enable`.
- `modules/nixos/nix.nix:93-94`: `appimage-run` and `flatpak` in `environment.systemPackages`.

The NixOS modules add those packages themselves: `programs.appimage` adds `cfg.package` (appimage-run; nixpkgs `nixos/modules/programs/appimage.nix:45`) and `services.flatpak` adds `flatpak` (`nixos/modules/services/desktops/flatpak.nix:38`). With both features selected the package set is unchanged; only two duplicate list entries disappear.

`modules/nixos/{appimage,flatpak}.nix` are deleted.
<!-- doctrine:section sec-5 -->
## Selection and flag removal

- `modules/features.nix`: delete the `hardware` group (both flags), `virt.qemu` and `virt.docker` (so the `virt` group goes), and `apps.appimage` / `apps.flatpak`. The `apps` group keeps only `cad`.
- `hosts/Sleipnir/features.nix`: delete the `hardware` and `virt` blocks and the `appimage` / `flatpak` lines from `apps`. Add `feature.virt.qemu.enable = true;` beside capsule, with a comment: a host property, because it needs KVM (DEC-021).
- `features/profiles/workstation.nix`: add `mkDefault true` for `feature.virt.docker`, `feature.non-nix-packages.appimage` and `feature.non-nix-packages.flatpak`.
- `virt.podman`: selected by nobody. `hosts.nix` gains the ADR-005 coverage target `coverage."Sleipnir+podman"`, which selects `virt.podman` and sets `feature.virt.docker.enable = false` (a plain definition beats the profile's `mkDefault`), so it evaluates without tripping the exclusivity assertion.
- `hosts/Sleipnir/config.nix`: delete the six `lib.optional` gates (appimage, docker, flatpak, microcode, qemu, ssd) and the unconditional `podman.nix` import, and add `./machine.nix` after `./hardware-configuration.nix`.
- Darwin reads none of these flags (research fact 10); Draupnir imports no profile, so it selects none of the new features.
- **Defaults change for future hosts.** The legacy `virt.qemu`, `apps.appimage` and `apps.flatpak` defaulted to true; tree features default off. A new NixOS host with no profile gets none of the four. With `workstation` it gets docker, appimage and flatpak, but not qemu, which a host selects itself (DEC-021). The first such host is likely RFC-001 W7's nixosvm.
<!-- doctrine:section sec-6 -->
## Code impact

| path | change |
|---|---|
| `hosts/Sleipnir/machine.nix` | new: microcode (less `shell_on_fail`) + ssd |
| `hosts/Sleipnir/config.nix` | import `./machine.nix`; six gates and `podman.nix` out |
| `hosts/Sleipnir/features.nix` | flags out; `feature.virt.qemu.enable = true` |
| `features/virt.nix` | `qemu`, `docker`, `podman` records |
| `features/non-nix-packages.nix` | new area: `appimage`, `flatpak` |
| `features/default.nix` | register the area after `virt` |
| `features/profiles/workstation.nix` | docker, appimage, flatpak |
| `modules/features.nix` | six flags out |
| `modules/nixos/user.nix` | `docker`, `libvirtd` out of `extraGroups` |
| `modules/nixos/boot.nix` | `boot.kernelParams = ["boot.shell_on_fail"]` |
| `modules/nixos/security.nix` | assertion: no rootful docker |
| `modules/nixos/programs.nix` | `programs.appimage` out |
| `modules/nixos/nix.nix` | `appimage-run`, `flatpak` out |
| `modules/nixos/{microcode,ssd,qemu,docker,podman,appimage,flatpak}.nix` | deleted |
| `hosts.nix` | coverage target `Sleipnir+podman` |
| `features-test.nix` | Sleipnir selection test |
| `README.md` | flag table, tree listing, intro line, `machine.nix` |
<!-- doctrine:section sec-7 -->
## Verification

1. **Gate per commit** (`mem.pattern.flakes.drv-gate`). Before the first edit, and after each of the three commits: `just drvs`, `just drvs-sets`, and these one-off evals of Sleipnir:
   - the unique sorted `environment.systemPackages` drvPaths;
   - effective group membership: the groups that exist (`attrNames users.groups`) and either list david in `members` or appear in `users.users.david.extraGroups`;
   - `boot.kernelParams`, sorted;
   - `fileSystems."/".options`;
   - the system-path link map: build `config.system.path` and list every link with its target (`find -type l -printf '%P -> %l\n' | sort`). A sorted package set cannot show which package won a path collision; this can.

   Each commit is compared with the one before it, so every diff is attributed to a commit. `just coverage` is also run after each commit.
2. **Expected diffs: Sleipnir's system toplevel only.** Home, Draupnir, packages, legacyPackages and templates must be identical at every step. The system diff must be explained entirely by its commit's row:

   | commit | allowed diff | proof |
   |---|---|---|
   | hardware | kernel command line order | sorted `kernelParams` identical; `fileSystems."/".options` identical |
   | virt | `systemPackages` order; `extraGroups` order and contents (`docker`, `libvirtd` out); `libvirtd.members` deduplicated | unique sorted package set identical; link map identical (`bin/docker` → docker); effective membership identical |
   | podman | podman removed: its packages, the `dockerCompat` shim, `virtualisation.podman` units and config, the `podman` group | removed packages are exactly podman.nix's list (less distrobox, still in home and system-path via dev.nix) plus the podman module's (`podman`, shim); every link-map change is a removal into one of them; `bin/docker` still → docker; effective membership loses only `podman` |
   | apps | `systemPackages` order, two fewer duplicate entries | `drvs-sets` count drops by exactly 2; unique sorted set identical; link map identical |

   The link map must be identical after every commit except podman's, whose changes must all be removals of podman's paths.

   Anything else is red: `nix-diff` it and stop.
3. **Resolver test** (`features-test.nix`, DEC-014 shape): `testSleipnirSelectsMigrated` resolves the real tree with `hosts/Sleipnir/features.nix` and asserts that `virt.qemu#nixos`, `virt.docker#nixos`, `non-nix-packages.appimage#nixos` and `non-nix-packages.flatpak#nixos` are among the NixOS modules and none of them among the home modules. Red first: write it before the records exist.
4. **Negative controls** (one-off, not committed; `mem.fact.nix.verify-closure-not-option`). Evaluate Sleipnir with each feature deselected in turn:
   - appimage: `appimage-run` absent from the system closure; `programs.appimage.binfmt` false.
   - flatpak: `flatpak` absent from system-path; `services.flatpak.enable` false. It stays in the drv closure as a library of plasma-workspace and xdg-desktop-portal.
   - qemu: `qemu_kvm` and `virt-manager` absent from the closure; `libvirtd` absent from effective groups.
   - docker: the `docker` package and `lazydocker` absent from the closure; `virtualisation.docker.rootless.enable` false.
   - podman (the positive direction, since Sleipnir leaves it off): `coverage."Sleipnir+podman"` has `podman` in its closure and `bin/docker` → podman's shim.
5. **Guards** (one-off evals, each must fail with our message):
   - Sleipnir with `virtualisation.docker.enable = lib.mkForce true`: the `security.nix` message, with or without `virt.docker` selected.
   - Sleipnir with `feature.virt.podman.enable = true` (docker still selected): the exclusivity message from the `docker` feature.
6. `just test` green; `grep` finds no `features.hardware`, `features.virt`, `features.apps.appimage` or `features.apps.flatpak` reads.
7. **Coverage:** `Sleipnir+podman` for the one feature no host selects (ADR-005, DEC-014). Sleipnir selects the other four.
<!-- doctrine:section sec-8 -->
## Docs and follow-ups

- **README**: remove the rows for `hardware.*`, `virt.*` and `apps.{appimage,flatpak}` from the flag table (`apps.cad` stays); add `non-nix-packages.nix` and the virt features to the tree listing; extend "snooze, openrgb and capsule have moved here"; one line on `hosts/<h>/machine.nix` as the home for machine config, beside the generated `hardware-configuration.nix` (DEC-019); docker is rootless only, enforced by assertion; docker and podman are exclusive, and podman is an off feature with a coverage target.
- **At reconcile**: RFC-001 § Target shape qualified by DEC-019, W4's "Sleipnir hardware" class renamed machine config, and the W3 row records SL-005; IMP-003 notes docker and libvirtd done, and that `dev`, `caddy` and `jackaudio` in `user.nix` also name groups that do not exist on Sleipnir; IMP-006 notes that W3 slices discharge it incrementally.
- **Follow-ups**: IMP-018 (podman replaces docker: select `virt.podman`, deselect `virt.docker` and give it a coverage target, supabase `.envrc` updates); IMP-016 (apps taxonomy, `apps.cad`); remaining W3 areas (games, ai, singletons, desktop); generic hardware features in W4; IMP-017 (site-bound config in printing.nix and network.nix: LAN, printers, IPs; outside DEC-019's machine-bound class).
