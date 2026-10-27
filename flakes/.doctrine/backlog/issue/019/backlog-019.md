# ISS-019: Jails binding ~/.emacs.d fail to launch: the directory no longer exists

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

## Evidence (2026-10-27)

`~/.emacs.d` does not exist on Sleipnir (the Emacs config is
`~/.config/emacs`). A jail that binds it is refused by bwrap at launch:

    $ jailed-pi --version      # satan-corpus devshell
    bwrap: Can't find source path /home/david/.emacs.d: No such file or directory

`workspaceDeps` and `ro-bind` are not `try-` variants, so a missing source is
fatal. Flakes naming `.emacs.d`: bough, forgettable, org-incremental-writing,
vk, satan-attrd, satan, satan-corpus (found during IMP-051 step 1; satan's
static deps may not; check per repo).

## Fix (proposed)

Per repo: `~/.config/emacs` if the jail needs the Emacs config, else drop the
entry. Fold into CHR-023 where that repo is still open (satan,
satan-corpus); the rest are one-line chores.

## Progress (2026-10-27)

satan: not affected (its `.emacs.d` line is commented out; `.envrc` names
`~/.config/emacs`). satan-corpus: fixed (`fda8ebe`, both binds →
`~/.config/emacs`). Left: bough, forgettable, org-incremental-writing, vk,
satan-attrd.
