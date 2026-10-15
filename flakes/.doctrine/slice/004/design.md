<!-- doctrine:section sec-1 -->
## Shape

DEC-016 and DEC-017 fix the shape: one rule for every evaluation.

> A factory supplies host identity plus one injected module. The evaluator builds pkgs. Local fixes are modules beside their consumer.

```
                 specialArgs                        injected module                                   pkgs built by
mkNixos   {inputs username hostname features}  platformModule: hostPlatform + mkAfter [agents] + stable   NixOS module system
mkDarwin  {inputs username hostname features}  platformModule: hostPlatform + mkAfter [agents] + stable   nix-darwin module system
mkHome    {inputs username hostname features}  homeModule: allowUnfree + [lem claude-desktop             Home Manager module system
                                               agents llm-agents] + stable                                   (over bare nixpkgs-home)
```

```
hosts/<h>/meta.nix  { kind; system; home?; }
  kind = nixos   ─> mkNixos  ─> nixosConfigurations.<h>        classes: nixos  [+ homeManager if home]
  kind = darwin  ─> mkDarwin ─> darwinConfigurations.<h>       classes: darwin [+ homeManager if home]
  home = true    ─> mkHome   ─> homeConfigurations."david@<h>"  (any kind)
```

- Each host is still resolved once (`selections`, DEC-006). Every factory takes that one selection (ADR-001 D5).
- `features` still carries legacy flags only (ADR-001, DEC-002). `stable` leaves specialArgs and becomes a module argument (`_module.args.stable`) set by the injected module, so every evaluation gets it, darwin included, without factory plumbing. It stays out of the package set: `callPackage` fills defaulted arguments from the package set, and `kicad`, its `base.nix` and `guile-cairo` declare `stable ? true`, so a `pkgs.stable` would break them (RV-009 F-2).
- NixOS and Linux home build exactly what they build today. Draupnir's darwin system changes deliberately, and Draupnir gains a home (DEC-017).

<!-- doctrine:section sec-2 -->
## Factories (`hosts.nix`)

1. **Bindings.** `agentsOverlay` is bound here only (the `flake.nix` binding goes, DEC-018). `stableModule = system: { _module.args.stable = import inputs.stable { inherit system; config.allowUnfree = true; }; }` replaces `mkStable`; it is the same import, so `stable.*` derivations stay identical. The four call sites keep `{stable, ...}:` unchanged. `_module.args` cannot feed `imports`; no call site uses `stable` there.
2. **`args = hostname: selection: { inherit inputs username hostname; features = selection.flags; }`**, used as `specialArgs` by mkNixos and mkDarwin and as `extraSpecialArgs` by mkHome.
3. **`platformModule = meta: { nixpkgs.hostPlatform = meta.system; nixpkgs.overlays = lib.mkAfter [(agentsOverlay meta.system)]; imports = [(stableModule meta.system)]; }`**, appended by mkNixos and mkDarwin in place of today's agents-only module.
   - Plain priority beats the `mkDefault` in Sleipnir's hardware config. The value is the same, so there is no derivation change (IMP-009).
   - `mkAfter` keeps host `config.nix` overlays first (`mem.fact.nix.merge-order`).
4. **mkDarwin** passes no `pkgs` (neither argument nor specialArg) and no inline import, so nix-darwin builds pkgs from `nixpkgs.source`, which is darwin's input and follows ours (research D1/D2). The two inline overlays are deleted (DEC-016).
5. **mkHome** passes `pkgs = import inputs.nixpkgs-home { inherit (meta) system; }`: no config, no overlays. Not `legacyPackages`, which carries nixpkgs' flake-only lib version-info overlay (`nixpkgs/flake.nix:234`) that Home Manager would inherit (`lib/eval-config.nix:27`) and today's import does not have (RV-009 F-6). `homeModule = system: { nixpkgs.config.allowUnfree = true; nixpkgs.overlays = [lem claude-desktop (agentsOverlay system) llm-agents.shared-nixpkgs]; imports = [(stableModule system)]; }` goes first in `modules`, followed by `hosts/<h>/home.nix`, then `selection.modules.homeManager` (DEC-007 order). The separate `lem` module goes; `lem` moves into this list.
   - Home Manager always re-imports nixpkgs from `config.nixpkgs` (HM `modules/misc/nixpkgs.nix:58`). The effective order today is `[lem claude-desktop agents llm-agents]` (module overlays before `pkgs.overlays`; measured, RV-009 F-6). The list above keeps it exactly.
   - **Gate-conditional** (DEC-016): if Linux home derivations differ, revert to building pkgs in the factory with the overlays baked in, and record the reason.
6. **Classes and homes.** `classesOf = meta: [meta.kind] ++ lib.optional (meta.home or false) "homeManager"` (kind values are the class names), tested by `checks.factories` (item 8). `homes` filters `hosts` (not `hostsOf "nixos"`) by `meta.home`. The `david` alias stays.
7. **Outputs** (DEC-018). `legacyPackages` (`import inputs.nixpkgs { inherit system; config.allowUnfree = true; overlays = [(agentsOverlay system)]; }`, linux systems) and `packages` move into this file's `flake` attrset unchanged. Their comments are corrected: the `agents` registry alias (`modules/nixos/nix.nix:9-25`) consumes them, not `nixpkgs`.
8. **Factory check** (DEC-016). `perSystem.checks.factories`, defined here beside the factories, is evaluation-only. It is not a switchable output (ADR-005 D3/D4); `just test` gains a line building `.#checks.$(nix config show system).factories {{home_override}}` beside `features`. It asserts:
   - **Overlay reaches module `pkgs`** (ISS-004). For every darwin configuration, extend it with one probe module and force the result's `system.drvPath`:
     ```nix
     ({pkgs, ...}: {
       nixpkgs.overlays = [(_: _: { factoryProbe = true; })];
       assertions = [{ assertion = pkgs.factoryProbe or false; message = "darwin module overlays do not reach module pkgs (ISS-004)"; }];
     })
     ```
     The assertion reads the `pkgs` argument modules actually receive, so a leftover `specialArgs.pkgs` fails it; reading `_module.args.pkgs` would not (RV-009 F-3). nix-darwin checks `assertions` when building `system`.
   - **Non-vacuous.** `darwinConfigurations ? Draupnir`, so an empty darwin set cannot pass.
   - **Classes.** `classesOf` over `{nixos, darwin} × {home, no home}` yields `[nixos]`, `[nixos homeManager]`, `[darwin]`, `[darwin homeManager]` (RV-009 F-5); `homeConfigurations ? "david@Draupnir"`.
9. **Header comment** rewritten for the rule above; the DEC-001 comment at `mkDarwin` goes.

<!-- doctrine:section sec-3 -->
## Draupnir (darwin host and home)

DEC-017.

- **Host directory.** `hosts/Davids-MacBook-Pro/` → `hosts/Draupnir/` (`git mv`). `meta.nix` gains `home = true`. `darwin/system.nix` already derives hostName, computerName and NetBIOSName from `hostname`; the machine is already called Draupnir.
- **`hosts/Draupnir/home.nix`** (new) mirrors `hosts/Sleipnir/home.nix`: imports `../../darwin/home.nix`; sets `home = { inherit username; homeDirectory = "/Users/${username}"; stateVersion = "24.11"; }` and `programs.home-manager.enable = true`. `home.username` was supplied by embedded HM; standalone needs it (research B1).
- **`darwin/home.nix`** becomes the darwin home base, the counterpart of `profiles/linux-desktop.nix`:
  - imports `../modules/home/shared` and `../modules/home/shared/cli.nix`, replacing the hand-picked list; gains `EDITOR`/`VISUAL`; `shpool.nix` is already reached via `emacs.nix` and is inert on darwin (research C4, C6);
  - keeps the kitty `darwinLaunchOptions` and `targets.darwin.defaults`;
  - sets `home.backupFileExtension = "backup"`, the policy embedded HM applied (`darwin/default.nix:28`), so every later `home-switch` keeps it, not only the bootstrap (RV-009 F-7);
  - keeps the nushell PATH hack and drops its `/etc/profiles/per-user/${username}/bin` entry, which no longer exists once no user has packages (nix-darwin `modules/users/default.nix:346`);
  - `home`, `stateVersion` and `programs.home-manager` move to the host entry.
- **`darwin/default.nix`** keeps the `system`, `brew` and `packages` imports and `nix.enable = false`; adds `nixpkgs.config.allowUnfree = true`; drops the embedded Home Manager block, its `specialArgs` and the now-unused arguments.
- **Overlays.** Draupnir has no local fix overlays. The direnv `doCheck` overlay is obsolete: unpatched direnv and mise are on cache.nixos.org for aarch64-darwin, so deleting it stops local direnv and mise builds. lix-tools has no consumer.
- **Untouched**: `darwin/nix-core.nix` and Draupnir's nix settings (IMP-014).
- **atuin, temporarily** (ISS-007): 18.23.0 is uncached for aarch64-darwin, so it is off on darwin in two places: `programs.atuin.enable = lib.mkForce false` in `darwin/home.nix`, and Linux-only in `modules/shared/cli/_packages/shell-ux.nix` `common` (position kept, so Linux derivations are unchanged). Restoring it undoes both and README step 4.

<!-- doctrine:section sec-4 -->
## Activation and cut-over

**Justfile.**

- `flake := if os() == "macos" { "path:" + justfile_directory() } else { "." }`. This replaces the unused `flake := "."`. Used by `home-switch`, `home-build`, `darwin-build`, `darwin-switch` and `_drvs`, so Linux keeps `.` and the Mac bypasses the bare `~/.git` discovery failure (README § Bootstrap macOS).
- **`agents` override everywhere** (RV-009 F-1). `flake.lock` locks `agents` as `path:/home/david/flakes/agents`, which does not exist on the Mac, and every evaluation now builds `agentsOverlay`. `agents_override := "--override-input agents path:" + justfile_directory() + "/agents"` joins both `system_override` (which already has it) and `home_override`, so home, darwin, drvs and `test` all carry it. On Linux it points at the same tree, so home derivations do not change (drvs gate). The lock drift itself (comment says GitHub, lock says path) is out of scope; it gets a backlog issue.
- `host := \`hostname -s\``. `darwin-build`/`darwin-switch` lose their hard-coded `host="Davids-MacBook-Pro"` default and use `{{host}}`.
- `drvs`/`drvs-sets` pick up `david@Draupnir` automatically (research E2), and gain the DEC-018 entries:
  - `packages`: `ps: set (builtins.attrValues ps)`;
  - `legacyPackages`: `lp: if lp ? stdenv then concatStringsSep " " (map (n: lp.${n}.drvPath) ["stdenv" "codex" "claude"]) else "none"` (flake-parts gives aarch64-darwin an empty key);
  - `templates`: `t: "${t.path} ${t.description}"`.
- Comments that become false are fixed: `justfile:9-10` ("Linux-only consumer"; already false, since mkHome consumes `agentsOverlay`), `flake.nix:12`, `overlays/agents.nix:10`.

**Cut-over on Draupnir** (README § Bootstrap macOS; run by the user). Build everything first, then activate only those prebuilt store paths, never a fresh flake build (RV-009 F-4):

```
1. build both, switch nothing:
     just host=Draupnir darwin-build            -> ./result-darwin
     nix build "path:$PWD#homeConfigurations.\"david@Draupnir\".activationPackage" \
       <home_override flags> --no-write-lock-file --out-link result-home
   note the current generation: sudo darwin-rebuild --list-generations | grep current
2. activate the prebuilt system (what `darwin-rebuild switch` does after building,
   darwin-rebuild.sh:241-248):
     sudo nix-env -p /nix/var/nix/profiles/system --set "$(readlink result-darwin)"
     sudo ./result-darwin/activate
                             embedded HM leaves; home packages leave PATH, dotfile links stay
                             (still held by ~/.local/state/home-manager/gcroots/current-home)
3. ./result-home/activate    first standalone generation; the embedded one is treated as old,
                             so orphan links are cleaned (research D4); collisions are moved
                             aside to *.backup (home.backupFileExtension)
4. new login shell: which emacs nvim zoxide; nu login finds them (atuin off, ISS-007)
5. thereafter: just home-switch     (the home config now installs the home-manager CLI)
```

Steps 2 and 3 build nothing. Step 2 is not offline: `homebrew.onActivation` updates and upgrades (`darwin/brew.nix:9-11`), so run the cut-over online (RV-009 F-8).

Between steps 2 and 3 nothing provides `nu`, and `/etc/profiles/per-user/david/bin/nu` is gone for good. A terminal started before the cut-over keeps it in `$SHELL` until quit and relaunched; the Mac-local zsh login hook must resolve nu by PATH (`command -v nu >/dev/null && exec -l nu`), which survives both layouts and a rollback. Found on Draupnir (PHASE-06).

**Recovery.** Standalone home does not depend on darwin activation finishing, so recovery runs forward, not back:

- **Step 2 fails** (for example in the homebrew stage): run step 3 anyway; it restores home packages and links. Fix the cause and re-run step 2 with the same `result-darwin`.
- **Step 3 fails** (for example a collision with an existing `*.backup`): fix it and re-run `./result-home/activate`. No network or build is involved.
- **Last resort**: `sudo darwin-rebuild --switch-generation <noted>`; not `--rollback`, which picks the highest generation below the current one, not necessarily the noted one (RV-009 F-9). Its activation re-runs embedded HM and restores the per-user packages, but it also sets the hostname back to `Davids-MacBook-Pro` (`darwin/system.nix:45-46`), so name the target explicitly afterwards (`just host=Draupnir …`) until the next switch restores `Draupnir`. Homebrew runs during rollback too.

The step-2-failure path and one rollback plus re-switch are exercised on Draupnir before the slice closes (sec-7).

<!-- doctrine:section sec-5 -->
## Code impact

| path | change |
|---|---|
| `hosts.nix` | `stableModule`, `args`, `platformModule`, `homeModule`, `classesOf`, `homes`, mkNixos/mkDarwin/mkHome, `legacyPackages`/`packages`, `perSystem.checks.factories`, header; `mkStable` deleted |
| `flake.nix` | `agentsOverlay`, `legacyPackages`, `packages` removed; stale `:12` comment; keeps inputs, wiring, templates |
| `default.nix` | deleted |
| `hosts/Davids-MacBook-Pro/` → `hosts/Draupnir/` | `git mv`; `meta.nix` `home = true`; new `home.nix` |
| `darwin/default.nix` | embedded HM block and args removed; `nixpkgs.config.allowUnfree` |
| `darwin/home.nix` | imports `shared` + `cli.nix`; `home.backupFileExtension`; host fields out; PATH hack line dropped |
| `features-test.nix` | `testMacSelectsNothing` classes `["darwin" "homeManager"]` (empty-selection fixture only; `classesOf` itself is tested in `checks.factories`) |
| `justfile` | `flake`, `host`, `agents_override` in `home_override`, darwin recipe defaults, `_drvs` ref, drvs entries, `test` builds `checks.factories`, comments |
| `overlays/agents.nix` | comment |
| `README.md` | § Bootstrap macOS (Draupnir, cut-over), § Feature flags (`:113-121`, `:239-240`), § Hosts (`:269-277`) |

Unchanged: the `stable` call sites (`modules/nixos/fonts.nix`, `modules/nixos/wayland_packages.nix`, `modules/home/linux/graphics.nix`), `features.nix`, the feature tree, profiles, `darwin/{system,brew,packages,nix-core}.nix`, `overlays.nix`, `perSystem.nix`, `modules/nixos/nix.nix`.

<!-- doctrine:section sec-6 -->
## Governance and docs

At reconcile, not during execution:

- **One REV** (formal revision, REV-001 precedent):
  - **ADR-003**: §Context and §Decision state both platforms run Home Manager standalone, with separate pins and activation. Remove "on Linux", "Darwin continues to embed Home Manager", and the REV-001 paragraph about darwin's embedded Home Manager receiving no projection.
  - **ADR-001** §Context: three evaluations per host, with standalone Home Manager on both platforms.
- **DEC-006 and DEC-007**: wording edits ("or darwin" → darwin [+ homeManager]; drop "no embedded-HM hook"). **DEC-001** keeps its choice; DEC-017 already replaces its deferral consequence (`references(concerns)` edge).
- **RFC-001** (direct edit): where-things-stand diagram, W5 note (unblocked; citation fixed to RV-001 F-7), W8 (ISS-004 and IMP-012 done), W9 (CHR-003 done).
- **Recorded, not solved**: ADR-005 D6 is weaker on darwin. A Linux-only `homeManager` feature selected on Draupnir no longer fails the "lands nowhere" check (DEC-017 consequence; QUE-001).
- **Backlog**: IMP-012, ISS-004, CHR-003, IMP-009 and CHR-004 resolve at close. IMP-010's darwin `home` remark becomes obsolete. IMP-014 is unaffected.
- README is updated during execution (sec-5).

<!-- doctrine:section sec-7 -->
## Verification and phasing

Gates:

- **`just drvs`**: baseline after phase 1 adds the DEC-018 entries, before any refactor; new files `git add -N` first (`mem.fact.flakes.git-add-n`).
  - Phase 2: identical everywhere, darwin included.
  - Phase 3: identical for every Sleipnir output, `packages`, `legacyPackages` probe and `templates`. Darwin changes by key (`Davids-MacBook-Pro` → `Draupnir`) and content. `david@Draupnir` is new.
- **`just test`**: resolver tests plus `checks.factories`, green.
- **Draupnir home parity**: package names of the new `david@Draupnir` versus the embedded `home-manager.users.david` at baseline. Expected delta: `home-manager` CLI, hm-session-vars; direnv and mise drvs change, now substitutable. `EDITOR`/`VISUAL` show in `home.sessionVariables`.
- **ISS-004 red/green**: `checks.factories` written first; its overlay assertion fails against today's mkDarwin (stale `specialArgs.pkgs`), then passes.
- **Lint**: `nix fmt`; statix and deadnix zero warnings.
- **Draupnir activation** (by human): cut-over steps 1-5 on the machine, then one `darwin-rebuild --switch-generation <noted>` and a re-switch with `host=Draupnir` to prove the last-resort path.

Phasing suggestion for `/plan`:

| phase | content | drvs expectation |
|---|---|---|
| 1 | CHR-004 gate entries, then baseline | n/a (baseline) |
| 2 | `args`, `stableModule` (appended to mkHome's `modules` for now), `platformModule` (IMP-009), `agentsOverlay` once, outputs move, `default.nix` deleted, header comments | all identical |
| 3 | `checks.factories` (red) → mkDarwin without pkgs, overlays deleted (green); `homeModule`; classesOf/homes; Draupnir rename + home; darwin/home.nix; testMacSelectsNothing | Linux identical; darwin changes; Draupnir home new |
| 4 | justfile (flake ref, host, drvs comments), README, remaining comments | identical to phase 3 |

The `agents_override` line lands in phase 1 with the gate entries, so every later gate run, and any Mac evaluation, already carries it.

`homeModule` sits in phase 3 for review, but it touches only Linux home and is gate-conditional. If it fails it reverts alone without blocking the darwin work.

