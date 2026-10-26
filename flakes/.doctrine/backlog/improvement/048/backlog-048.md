# IMP-048: W6 — Quotient roots cover every /workspace repo

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

Programme W6. `~/.config/quotient/policy.src.json` `roots` lists 6 of the 14
`/workspace` repos as `~/dev/...` paths (plus emacs, `.local/src`, quotient).
Quotient canonicalises the call's cwd, so `/workspace/x` resolves to
`~/dev/x`.

Want: every `/workspace` repo is a root. Candidate: generate roots from
`/workspace/*` (resolved) in the justfile's `policy-install`, so the symlink
set is the single list.

Open: whether "aliases" means `/workspace` paths as root entries (check
whether quotient canonicalises root entries too) or just coverage.
