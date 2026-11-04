# IMP-060: Re-lock or migrate repos whose jails predate the host-path Doctrine bind

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

From RV-047 F-3 (SL-023 audit). `doctrine install` now bakes
`~/.local/share/doctrine/bin/doctrine` into the shared jail home's codex config
and into each re-baked repo's pi extension. Jails built from an older `agents`
pin bind Doctrine only at `/run/doctrine-bin`, so that path does not exist in
them.

Repos with a codex jail, no own host-path bind and no `use_dev_envs`: satan,
satan-attrd, www, org-incremental-writing. Checked pins: 19b9740e, 84efebe6.

Not run: confirm the failure in one of them first. Then move each to
`use_dev_envs`, or re-lock `agents` to a revision with the host-path bind.
Needs a published pin with PHASE-02 (RV-047 F-4). The redundant own binds in
the other project flakes go in the same pass.

## Finding (2026-11-04)

The failure this item predicted did not occur. The operator launched a jail in
each repo and `~/.local/share/doctrine/bin/doctrine` was reachable in all of
them except screwtape, which lacks `jailed-shell`. Also, satan and www have
`makeJailedCodex` commented out, so the repo list above overstated.

So there is no regression to fix. What remains is the original aim: bring each
repo in line with the dev-envs approach (`use_dev_envs`, dropping its own
Doctrine binds), one repo at a time, as each is next worked on. Screwtape's
missing `jailed-shell` is the first misalignment found; its `.envrc` is
`use flake` and its `agents` pin is a plain GitHub URL.
