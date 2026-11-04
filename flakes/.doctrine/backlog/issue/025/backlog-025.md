# ISS-025: dev-envs stub check fails where the stub's locked store path is absent (fresh machine, GC)

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

Found in SL-023 PHASE-03 (2026-11-04, Lix 2.95.4); detail in
mem.fact.flakes.relative-path-input-lock.

`dev-envs/flake.nix` takes its stub fixture as `project.url = "path:./stub-project"`.
The lock's `narHash` for that node pins the stub's content, and evaluation reads
the store path with that hash rather than the directory beside the flake.

- Edit the stub without `nix flake update project` → the checks evaluate the old
  stub silently (PHASE-03 hit this: `STUB_DEV_ENV` missing from every launcher).
- The store path absent (fresh machine, or GC: nothing roots it) → every
  `dev-envs` evaluation without `--override-input project` fails:
  `cannot fetch input 'path:./stub-project?…' because it uses a relative path`.
  Reproduced in a scratch copy. So `just test`'s `checks.stub`/`dev-env`/
  `quotient-forms` lines fail there. Real use (`use_dev_envs`,
  `bin/dev-envs-forms`) overrides `project` and is unaffected.

Options: `just test` passes `--override-input project path:…/dev-envs/stub-project`
(always current, no lock reliance); or move the stub out of the inputs.
