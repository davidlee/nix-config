# Guix

`~/guix` holds the Guix configs and the notes for running this setup on Guix
System. It is tracked in the home repo (`nix-config`), so it outlives any one
machine. The current Guix host is a VM, run under quickemu from `~/vm`
(untracked: disk image, sockets, quickemu config). Current work: make it
a daily driver. Emacs runs; next is packages and non-Emacs amenities. Start
with "Next session" in `PLAN.md`.

## Access

- Start the VM: `cd ~/vm && just run` (`quickemu --vm guix-1.5.0.conf`).
- Log in: `ssh guix` (passwordless). Run commands with `ssh guix '...'`.
- `~/vm/guix-1.5.0/` holds the disk image and live quickemu sockets. Don't touch it
  while the VM is running.

## Layout

| Where | What |
|---|---|
| `~/guix/home.scm` | Guix Home config. On the VM: `guix home reconfigure ~/guix/home.scm` |
| `~/guix/system.scm` | The VM's `/etc/config.scm` (installer-generated; disk UUIDs are this VM's). Copy back and `sudo guix system reconfigure` after editing |
| `~/guix/zsh/zshrc` | Guix's `.zshrc` stub (via `home.scm`'s `zsh-stubs`); sources the shared `~/.config/zsh` files |
| `~/guix/channels.scm` | Channels (Guix plus nonguix). The VM's `~/.config/guix/channels.scm` links here |
| Host `~/.config/emacs` | Emacs config working copy; the source of truth. Run `just check` before committing |
| Host `~/flakes/emacs/emacs.nix` | Nix package list for Emacs; the reference for what the config needs |
| VM `~/.config/emacs` | Installed config; update with `git pull`, after `ssh-add` (otherwise use anonymous HTTPS) |
| VM `~/dev/satan`, `~/dev/malebolge`, `/workspace/sediment` | Private repos, cloned from host bundles |
| VM `~/dev/org-incremental-writing` | Symlink to `/workspace/org-incremental-writing` |
| VM `~/_compost` | Backups of the previous Emacs config, Home config and `custom-vars.el` |
| VM `~/.git` → `~/.cfg` | Home repo (`nix-config`), sparse: all but `.config/git/hooks/post-commit` (SATAN). Shared dotfiles, and `~/flakes` as the Nix reference. Never `git stash` or `git clean` here |
| VM `~/notes` | Clone of the notes repo |
| VM `/tmp/emacs-probe` | Throwaway test environment; assume it can vanish on reboot |

## VM facts

- Guix `aada33c` plus the nonguix channel. Emacs is `emacs-pgtk` 31.1, with
  native compilation and tree-sitter.
- 16 cores, 15 GiB RAM, about 13 GB disk free at last check.
- `sway` is configured, but no graphical session runs by default.
- `ssh-agent` runs under Home Shepherd (`herd status ssh-agent`). It starts with no
  keys, and only shells opened after generation 13 have `SSH_AUTH_SOCK`.

## Rules

- Host repos and the VM's real home are the user's. Test in a throwaway copy
  first; change them only as `PLAN.md` directs.
- Never run `git stash` or `git checkout`. Commit only when asked.
- Don't start a full-init Emacs on the host, even as a separate daemon. It
  rewrites live state such as `recentf`. Use `just check` or a batch load of
  `early-init.el`.
- The user may commit in the same repos while you work. Check `git log` and
  `git status` before committing, and commit by explicit path.
- The user may be working on the VM at the same time. Unexplained new files
  there are probably theirs; leave them alone and ask.

## Probes

`probes/` keeps the test harness and its data. The scripts expect to run from
`/tmp/emacs-probe` on the VM, so copy them there first. They also expect
`/tmp/guix-pkgs.txt` and `/tmp/located.txt`, and profiles at
`/tmp/emacs-probe/profile` and `/tmp/emacs-probe/wm` (`sway`, `grim`).

| File | Purpose |
|---|---|
| `gui.sh` | Boot a throwaway copy in a real frame under headless sway, then screenshot |
| `gui-real.sh` | The same, for the installed config in the real `HOME` |
| `env.sh` | Isolated environment for batch runs |
| `nw-probe.sh` | Boot a throwaway copy with `emacs -nw` in a pty from a login shell. Copy `nw-dump.el` to `/tmp` first |
| `nw-dump.el` | Report `-nw` post-init state to `/tmp/nw-probe/report.txt`, then exit |
| `dump.el` | Report post-init state to a file (use with `gui.sh`) |
| `gsweep.el` | Require every module in a live frame, with backtraces |
| `melpa.el` | Install the libraries Guix lacks from MELPA |
| `ghostel-test.el` | Download and load the prebuilt `ghostel` module |
| `probe.sh`, `sweep.el` | Early daemon and batch versions; superseded by `gui.sh` and `gsweep.el`, and `probe.sh` has the `XDG_CONFIG_HOME` leak |
| `resolve.txt` | Each Nix package and its Guix version, or `MISSING` |
| `guix-pkgs.txt` | The Guix package names that resolved |
| `located.txt` | Missing names marked `LOADABLE` or `absent` |
| `host-closure.txt` | Emacs packages and versions on the host |
| `packages.tsv` | Every Nix host package: its Guix or nonguix name, or `MISSING` with a gap class. See `PLAN.md` |

## Testing Emacs on the VM

Isolate from the real home:

- Setting `HOME` is not enough. `XDG_CONFIG_HOME` is exported and wins, so unset
  `XDG_CONFIG_HOME`, `XDG_CACHE_HOME`, `XDG_DATA_HOME` and `XDG_STATE_HOME`, and
  pass `--init-directory`.
- Source a profile's `etc/profile` with `set +u`; it references unset variables.
- `guix shell --root=PATH` fails if `PATH` already exists. Remove the symlink
  first.

Observe a real boot:

- Batch mode and daemons can't answer prompts or show a frame. Run under
  headless sway and screenshot with `grim`:
  `WLR_BACKENDS=headless WLR_LIBINPUT_NO_DEVICES=1 WLR_RENDERER=pixman`.
- If Emacs produces no output, take a screenshot. A hang is usually a minibuffer
  prompt.
- An init error stops everything after it, which hides later failures and makes
  a run look cleaner than it is. Compare the feature count between runs. To see
  every failure at once, `require` each module from `init.el` in turn, catching
  errors and using `handler-bind` to capture the backtrace at the signal.

Other traps:

- `guix package -A` pads names with spaces when piped. Trim before matching.
- A name missing from Guix may still load: it can be bundled in another package
  or built into Emacs. Confirm with `locate-library`.
- The ERT command in the config's `Justfile` uses `-Q`, which skips `elpa/`.
  Run `package-initialize` first, or MELPA and `:vc` packages show up as false
  failures.
