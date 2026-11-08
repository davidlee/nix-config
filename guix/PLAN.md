# Plan: the Guix VM as a daily driver

## Next session: start here

Emacs runs (below). The current phase is the rest of the system: packages and
the non-Emacs amenities. Session of 2026-11-08 (second): inventory done,
`home.scm` and `system.scm` extended, not yet applied. Apply in this order:

1. User (needs sudo): `sudo cp ~/guix/system.scm /etc/config.scm &&
   sudo guix system reconfigure /etc/config.scm`. Adds nonguix substitutes
   (else `firefox` builds from source) and makes zsh the login shell.
2. Commit and push the home repo on the host; on the VM `git pull`, then
   `guix home reconfigure ~/guix/home.scm`; log in again.
3. Verify a login zsh: antidote plugins clone, p10k prompt, `SSH_AUTH_SOCK`
   is the Shepherd agent (`$XDG_RUNTIME_DIR/ssh-agent/socket`), `y`, atuin ^R.

Follow-ups the user asked for:

- [ ] Grow the VM disk for headroom (it was grown once already). The VM must
      be stopped: `~/vm/guix-1.5.0/` holds the image.
- [ ] Then add `kitty` back to `desktop-tools` (skipped for disk, +290 MiB).

- **Inventory.** `probes/packages.tsv`: each package of the Nix host
  (`homeConfigurations."david@Sleipnir"` `home.packages`, and Sleipnir's
  `environment.systemPackages` not already in it), its Guix or nonguix name
  and version, or `MISSING` with a gap class. Regenerate by evaluating those
  attributes with `nix eval --apply 'map (p: p.pname or p.name)'` and
  matching against `guix package -A`. Counts, home / system:

  | Status | Home | System |
  |---|---|---|
  | Guix or nonguix (antidote: pinned `git-checkout`) | 195 + 1 | 250 |
  | `false-friend` (same name, other software: `pls tre chroma selene watcher`) | 5 | 0 |
  | `MISSING`, by gap class: | | |
  | `cli-long-tail` (mostly Go/Rust/Node CLIs: lazygit, gum, glow, ov, carapace, television, ghostty, xh...) | 96 | 16 |
  | `nix-machinery` (Nix, NixOS, home-manager tools): skip | 12 | 52 |
  | `own-tooling` (SATAN, screwtape, quotient, zmx, capsule...): wait on the Nix decision | 11 | 12 |
  | `proprietary` (1password, spotify, discord, claude-desktop...): Flatpak or Nix | 11 | 2 |
  | `other-desktop` (COSMIC, Plasma, noctalia...): skip, the VM runs sway | 5 | 46 |
  | `sway-extra` (swayosd, sway-launcher-desktop, wl-* helpers) | 4 | 32 |
  | `host-hardware`, `games`: skip on the VM | 0 | 20 |

- **Inference, not tested:** the Nix decision settles most of the gaps.
  With Nix on Guix (`nix profile` or standalone home-manager), the long tail,
  own tooling and proprietary apps come from the existing flake. Without it,
  packaging ~100 CLIs for Guix is days of work; a personal channel for the few
  that matter (`ov`, `lazygit`, `carapace`, `television`, `ghostty`) is the
  middle path.
- **Installed by `home.scm` lists:** `dotfile-tools`, `cli-tools`,
  `dev-tools`, `desktop-tools`. The user's rule for disk: cull GUI packages
  first, and grow the disk rather than cut deep. Skipped packages are commented
  in `home.scm` with their measured added size. `fastfetch` is skipped because
  it builds ZFS from source. `pandoc` (about 4 GiB of Haskell closure;
  `ripgrep-all` shares it) is kept and is the first cut if disk runs short.
  Projected home closure: about 9 GiB without the nonguix apps (it is 5 GiB
  now). A `guix gc` on 2026-11-08 freed 32 GiB after a build filled the disk.
- **Open decision, the user's:** whether Nix goes on top of Guix, and at what
  level. Until then, SATAN, Malebolge, oubliette and direnv stay off.
- **Useful mechanism:** the home checkout's sparse exclusions
  (`git sparse-checkout list`) can keep host-only files off Guix hosts. The user
  found this potentially useful beyond the SATAN hook.

## Goal

Run the current Emacs config as a daily driver on the VM, installed for real
rather than in a throwaway copy, without breaking the Nix host.

**Approach:** Guix supplies Emacs and most packages. MELPA fills the gaps, on
Guix only. Estimate: half a day. This is a judgement, not a measurement.

**Out of scope:** a fully Guix-native package set (about 30 hand-written
definitions, probably 1-2 days) and Nix on Guix (untested). Revisit either if
the overlap between package.el and Guix causes trouble.

## Status (2026-11-08)

**Installed and booting on the VM.** Steps 1-6 are done, except as listed under
"Remaining". The last boot, in a real pgtk frame under headless sway:

- Full init, 1105 features, 2.5s warm (41s on the very first boot).
- `foxglove-dark` theme and the Nerd font working. `meow` was confirmed in the
  probe, not re-checked on the install.
- The `satan-attrd` startup error is gone: SATAN is skipped on Guix (below).

ERT on the VM, with `package-initialize` run first: 545 of 551 as expected,
3 failed, 3 skipped. Host `just check`: 549 of 551 passed, 2 skipped, 0 failed.

Landed in `emacs-config` as `682798c` and `e2b1971`, on `origin/main`, tracked
as `CHR-012`. The slice process was waived by the user for this change.

Terminal boot (`emacs -nw --debug-init`, throwaway copy, pty, login shell):
no init error, 1064 features, 2.8s, `denote` loaded, `meow` on, `foxglove-dark`,
256 colours. Not yet used interactively.

With the Nix edge cut (`emacs-config` `b807478`, pushed): no
`satan-attrd`, patch runner or `nu` messages, 1003 features, 2.8s.

**Nix edge.** `satan`, `malebolge` are skipped on Guix in `apps/dl-satan.el`
until the user decides whether Nix goes on top of the VM, and at what level.
`oubliette` has no Emacs references. `lang/dl-nushell.el` loads only where the
`nu` grammar exists, so NixOS keeps it. direnv stays unused on the VM: it only
loads Nix, so `direnv: denied (~/notes)` is expected. The `sleipnir-doctor`
tooling checks SATAN machinery, so it's out of scope on the VM for now.

## Remaining

- [ ] Open a `ghostel` terminal by hand. The module loads, but the automated
      terminal test produced no output, so this is unconfirmed.
- [ ] `dl-nix/apheleia-formats-with-alejandra`: needs `alejandra`, which Guix
      doesn't have.
- [ ] `dl-project/keeps-unrestored-layout`: fails on the VM only. Probably
      `project-x` skew: the VM has `e6a308d` (July), the host `f2650cf` (April).
      Inferred, not tested. Host `elpa/` may need updating, not the VM.
- [ ] `dl-project/here-infers-from-buffer-not-tab-root`: fails on the host too
      under `package-initialize`, so it's a harness effect, not Guix.
- [ ] `ssh-agent` (Home Shepherd, since generation 13): the user confirmed it
      works after `ssh-add`. Its socket was recreated at 07:59 with no keys,
      probably after a re-login, so keys don't survive a session. Consider
      `AddKeysToAgent yes` in `~/.ssh/config`, or a keyring.
- [ ] `/workspace/sediment` has no remote, because the host copy has none.
- [ ] `custom-vars.el` and `custom-vars.eln` on the VM: Emacs regenerates these,
      so they keep showing as changes. Don't commit them. Consider ignoring them.
- [ ] Close `CHR-012` once the above are settled.
- [ ] Section 7's untested list: eglot and LSP, `jinx`, `auth-sources`, Postgres
      SATAN features, a day of interactive use.

## Shared home (2026-11-08)

The home repo (`nix-config`, worktree `$HOME`) is checked out on the VM, sparse:
everything except `.config/git/hooks/post-commit` (SATAN's hook), so `~/flakes`
is present. `/workspace/nix-config`, a second clone, was removed. `guix/home.scm`
(tracked, `8d1e6ead`) is the Guix side: packages, plus stubs that load shared
dotfiles. Guix owns `sway/config`, which includes the shared `sway.conf`.
`.gitconfig` has a pathless `emacsclient`, and `git-delta` is installed for its
pager. Home generation 14.

- [x] zsh stubs in `guix/home.scm` (`zsh-stubs`, with `guix/zsh/zshrc`)
      source `.config/zsh/{env,profile,initEarly,init,login,logout}.zsh` in
      home-manager's order. Supplied: fzf, atuin, eza aliases, `y`. Dropped
      (not in Guix): carapace, television, `lg` (lazygit); direnv's hook (off
      until the Nix decision). zoxide comes from `init.zsh`. `$PAGER` falls
      back to `less` without `ov`. antidote is a pinned `git-checkout` linked
      at `.config/zsh/.antidote`. zsh is the login shell in `system.scm`.
      Not yet applied (see "Next session").
- [x] `env.zsh` set `SSH_AUTH_SOCK` to gcr's socket unconditionally, hiding
      the Shepherd agent. Now only when that socket exists (systemd creates
      it at user-manager start on NixOS, so the host is unaffected).
- [x] Tools for the dotfiles: fzf, eza, bat, atuin, tmux, zoxide, yazi, most.
- [ ] `sway.conf` on Guix. Findings: every startup `exec` is NixOS-flavoured
      (`dbus-update-activation-environment --systemd`, the
      `systemctl --user daemon-reexec` line, `gnome-keyring-daemon
      --components=ssh`, 1password, slack, ghostty bindings). On Guix they fail
      silently; none blocks the session. `gnome-keyring`'s ssh component is
      not installed, so the Shepherd agent stays in charge. Proposal (needs
      the user, touches the Nix host): move the startup block out of
      `sway.conf` into per-host includes, home-manager's `extraConfig` on Nix
      and the `sway/config` stub in `home.scm` on Guix.
- [x] Shebangs: all `.local/bin` and waybar/sway scripts use `/bin/sh` or
      `/usr/bin/env`, which Guix has, except `waybar/scripts/stopwatch`
      (`/run/current-system/sw/bin/env python`), now `/usr/bin/env python3`.
      Four `.local/bin` scripts need `nu`; `nushell` is in `cli-tools`.

## Traps found during install

- Home Shepherd is started by `~/.guix-home/on-first-login` from whichever
  session logs in first, and inherits that session's stdout and stderr. If that
  is a non-interactive `ssh guix '...'`, the command runs but `ssh` never
  exits, because `sshd` waits on Shepherd's copies of the pipes. Killing the
  session kills Shepherd and can orphan its `ssh-agent`. It doesn't happen
  while an interactive login already has Shepherd running. Seen 2026-11-08;
  no fix yet (candidates: start Shepherd with its output redirected, or keep
  a login session open).
- A shell opened before `guix home reconfigure` keeps the old `EMACSLOADPATH`,
  so Emacs started from it can't find Guix packages (`denote` was the first
  failure). Log in again after every reconfigure.
- `Unable to activate package` lines at startup are `package.el` noise: it can't
  see Guix dependencies. `treemacs`, `org-super-agenda`, `org-ql`,
  `meow-tree-sitter` and `dired-sidebar` all resolve through `load-path`.
- `package-vc` compiled `org-timeblock` badly (`Invalid function:
  compat-version`). Delete `elpa/org-timeblock/*.elc` after a fresh install.
  This will recur on a reinstall until it's fixed.
- `ghostel`'s `master` can be ahead of its latest release, so its default module
  download 404s. Call `(ghostel--download-module DIR nil t)` to use the latest
  release; `0.61.0` loaded alongside `0.62.0` Lisp.
- `ghostel` installs `ghostel-module.so` in `elpa/ghostel/`, which a fresh
  `elpa/` loses.

## 1. Decisions (made 2026-11-08)

- Config changes are committed on the host and pushed, then pulled on the VM,
  provided they don't break the Nix host.
- The config moves from `/workspace/emacs-config` to `~/.config/emacs` on the
  VM, replacing the stock `init.el`.
- `~/_notes` replaces the `~/notes` stub.
- `meow` and `solaire-mode` build from unpinned `master`.

## 2. Config changes (host repo)

Add one Guix predicate, for example `(file-directory-p "/gnu/store")`. NixOS
also has `/run/current-system`, so that path won't do.

- [ ] `early-init.el`, on Guix only: set `use-package-ensure-function` to
      `ignore`. `:ensure` can't see Guix packages.
- [ ] On Guix only: enable MELPA, GNU and NonGNU archives, and install an
      explicit list of packages (section 4). `package-archives` stays nil on Nix.
- [ ] `core/dl-faces.el`: add `(require 'hl-line)`. Without it, init aborts with
      `Invalid face: hl-line`. Write the failing test first.
- [x] `hunk-notes` and the `org-timeblock` fork are `:vc` entries in
      `core/dl-guix.el`. A `use-package` `:vc` stanza would also clone on Nix.
- [ ] `core/dl-path.el`: `my/exec-dirs` lists only Nix paths. Add the Guix
      profiles if a GUI-launched Emacs can't find its tools.
- [ ] Confirm the Nix host still boots and its ERT suite still passes.

## 3. Update the VM clone

- [ ] Pull `/workspace/emacs-config`. Its `custom-vars.el` has local changes;
      review them first.
- [ ] Delete its `elpa/`. It is left over from an aborted attempt and blocks
      startup on an "Overwrite previous checkout?" prompt.

## 4. Guix Home manifest

Add to `~/home-configuration.scm`:

- `emacs-pgtk`, `emacs-ef-themes`, and the 124 packages Guix provides.
  Regenerate the list from `~/flakes/emacs/emacs.nix`.
- Transformations: `emacs-meow` and `emacs-solaire-mode` from `master`.
  - `meow` 1.5.0 lacks `meow-motion-define-key`, which `core/dl-keymap.el`
    needs.
  - `solaire-mode` 2.0.5 fails with `void-variable for` on `load-theme`.
- Tools: `ripgrep fd git just direnv gcc-toolchain enchant`.
- Fonts: `font-nerd-jetbrains-mono font-google-noto font-adobe-source-sans`.
- Grammars: `tree-sitter-` plus `bash cpp css go html javascript json nix python
  rust toml typescript yaml zig`.

Guix lacks 30 libraries. Install these 29 from MELPA:

```text
australia-holidays breadcrumb buffer-terminator comment-dwim-2 copy-as-format
dired-toggle dogears flyover gptel-inline macher magit-filenotify
markdown-preview-eww markdown-toc minuet molokai-theme nano-agenda
nushell-ts-mode org-alert org-gcal org-mcp org-review org-srs popterm quick-sdcv
ready-player slim-mode treesit-fold visual-regexp-steroids zoom-window
```

The 30th, `hunk-notes`, is covered in section 2. A grep found no reference to
these 7, so consider dropping them: `australia-holidays`,
`dired-toggle`, `gptel-inline`, `markdown-preview-eww`, `molokai-theme`,
`nano-agenda`, `org-srs`. The grep can miss hook-only use, so check first.

## 5. Private repos and notes

- [ ] Clone to `~/dev/satan`, `~/dev/malebolge` and
      `~/dev/org-incremental-writing`.
- [ ] Clone to `/workspace/sediment`; the path is hardcoded in
      `apps/dl-sediment.el`.
- [ ] Copy `elpa/org-timeblock` from the host.
- [ ] Install `satan-attrd`, or accept the startup error from `dl-satan`.
- [ ] Put the notes at `~/notes` (section 1). Without them, startup blocks on a
      "Non-existent agenda file" prompt.

## 6. First boot

- [ ] Start Emacs. The first run clones the `:vc` packages and takes longer.
- [ ] Install the `ghostel` module with the prebuilt download. Building from
      source needs Zig 0.17 or later; Guix stops at 0.16.

## 7. Verify

- [ ] Boot in a real frame with no `use-package` errors, except any accepted in
      section 5.
- [ ] ERT, with `package-initialize` run first. Triage the known failures:
  - `dl-nix/apheleia-formats-with-alejandra`: a program is missing.
  - `dl-project/here-infers-from-buffer-not-tab-root`: undiagnosed.
  - `dl-project/keeps-unrestored-layout`: undiagnosed.
  - `dl-modeline-test`, `dl-org-iw-test`: need `org-iw`; section 5 should fix
    both.
- [ ] Check what the probe did not cover:
  - opening a `ghostel` terminal
  - eglot and LSP
  - `jinx`
  - `auth-sources`: `secrets:Login` needs a running Secret Service
  - SATAN features that use Postgres
  - a day of interactive use

## Known gaps

- Not in Guix: the `nu` grammar, `tsx` as a separate grammar, `nixd`,
  `tinymist`, `statix`, the Geist font.
- Not checked in Guix: `claude`, `pi`, `doctrine`, `bough`, `op`, `alejandra`.
- `package.el` and Guix overlap, which causes the harmless `transient`
  "activated too late" warning.
- `apps/dl-claude.el:23-24` calls variables as functions. It errored in several
  runs but not the last. Check it on the host too.
