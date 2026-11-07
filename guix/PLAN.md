# Plan: the Guix VM as a daily driver

## Next session: start here

Emacs runs (below). The next phase is the rest of the system: get as many of
the user's packages as possible from Guix, nonguix or elsewhere, and set up
the non-Emacs amenities. The open items are under "Shared home"; take them
first.

- **Package inventory.** The Nix package set is in `~/flakes` (now on the VM
  too): `modules/home/cli.nix`, `features/*.nix`, `features.nix`, `hosts/`.
  Map each package to Guix, nonguix, or `MISSING`, as `probes/resolve.txt`
  did for Emacs. Trim names from `guix package -A` (see Traps). Then decide
  for each gap: skip, package it, or another source (Flatpak, binary, Nix).
- **Where packages go.** `~/guix/home.scm`, tracked in the home repo. Edit it
  on the host, push, then `git pull` on the VM and
  `guix home reconfigure ~/guix/home.scm`. Keep separate lists by purpose, as
  with `emacs-tools` and `dotfile-tools`. System-level services (sway session,
  seat, audio) are in the VM's system config, not this file; not yet looked at.
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

- [ ] zsh stub in `guix/home.scm` sourcing `.config/zsh/{env,init}.zsh`; make
      zsh the login shell. home-manager's `.zshrc` also wires fzf, carapace,
      television, eza aliases and `y`/`lg`: supply or drop on Guix.
- [ ] Missing tools for the dotfiles: fzf, eza, bat, atuin, tmux.
- [ ] `sway.conf` on Guix: `systemctl` lines, autostarted apps, gnome-keyring's
      ssh component versus the Shepherd `ssh-agent`.
- [ ] Audit `.local/bin` and `waybar/scripts` shebangs (`/run/current-system/sw`).

## Traps found during install

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
