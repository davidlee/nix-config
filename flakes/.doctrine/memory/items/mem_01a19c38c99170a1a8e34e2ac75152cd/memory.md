Read 2026-11-02 while designing SL-022's form story.

- `quotient/nix/form-family.nix` (v0.6.0 and the `~/dev` checkout alike) takes
  `packages ? [ ]`, and that is what a form's PATH is built from — so a caller can
  put a project's `dev-tools` inside a delegate's world.
- The family returns `{ read, write, baseline, prefix, bwrap, exposure, protect,
  secretEnvNames, network }`, names its launchers `jailed-<prefix>-<capability>`
  (default prefix `quotient`), and `flake.nix` exposes `checkFormFamily`
  (`nix/check-family.nix`) — the static guard that a form's bwrap line is plain
  words.
- `agents/jailed-agents.nix`'s `quotientFormFamily` strips only `quotient`,
  `client` and `postureFlags` from its arguments and forwards the rest to
  `mkFormFamily`, so `packages`, `env`, `secretEnv`, `piFiles`, `protect` etc.
  pass through from the jail lib's wrapper. It also fills `pkgs`, `jail-nix`, `pi`
  and the gateway's url/key/models itself.

Consequence: the *consumer* keeps a quotient input and the project needs none,
which is the whole point of the producer/consumer split (SL-022 DEC-102).

## Which executable the host's Quotient actually runs

Sharpened 2026-11-02 (SL-022 PHASE-02) by building a form and resolving it.

A family member is **two** derivations. `family.<c>` is
`writeShellScriptBin "quotient-<c>"`, whose text takes an absolute session
directory as `$1` and then `exec`s
`<launcher>/bin/jailed-quotient-<c>` — the launcher being a *different* store
path. So the form package's `bin/` holds `quotient-<c>` only.

`<root>/.quotient/forms/<c>` must therefore point at **`<form>/bin/quotient-<c>`**
(`quotient/docs/nix-forms.md:101,131`). `src/server/forms.ts`'s
`probeProjectForm` resolves the link and requires an executable regular file
outside every writable path, so a link to `bin/jailed-quotient-<c>` is dangling
and refused. A linker that links the launcher "because the design said the family
names its launchers that way" produces a broken link that only shows up when
`quotient allow` runs.
