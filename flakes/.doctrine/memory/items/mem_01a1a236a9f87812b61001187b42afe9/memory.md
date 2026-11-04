Measured 2026-11-04 (SL-023 PHASE-05), Lix 2.95.4.

`nix build path:~/flakes/dev-envs#… --override-input project git+file:… --no-write-lock-file`
does NOT use the overriding project's own flake.lock for the project's inputs:

- an input whose node exists under the parent's lock entry for `project` (the
  stub's `nixpkgs`) reuses the parent's lock — the consumer's nixpkgs;
- an input the parent never locked is locked fresh (latest upstream).

So a "producer" flake consumed through an override is built at pins it never
chose. Doctrine's dev-tools came out with different nodejs/rust/eslint versions.

Fix used in dev-envs: declare the input `flake = false` and evaluate it with
flake-compat, which reads `${src}/flake.lock` and fetches each locked node:

    projectFlake = (import flake-compat {src = project;}).outputs;

Verified: same dev-tools drv/out path as the project's own flake.
Guard: `checks.project-pins` (stub-project/flake.lock pins a nixpkgs the
consumer does not), run by `just test` under `--override-input project`.
Without the override the check proves little: the parent lock would apply.

Related: mem.fact.flakes.relative-path-input-lock, the stub's lock narHash.
