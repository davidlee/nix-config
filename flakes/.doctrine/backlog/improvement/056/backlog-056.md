# IMP-056: Layered dev-env consumer for Doctrine (SL-022 step 3)

Step 3 of the layered dev-env split proven in SL-022 (see SL-022 § Follow-Ups).
SL-022 made `dev-envs/` a consumer of a project's `dev-tools` output, and proved
it on Smut, a project with packages and two shell commands only. Doctrine is the
first consumer with an environment beyond packages, so this step designs the
customisation API the consumer needs.

- **Doctrine** — the spec-driven governance CLI this repo's agents run under
  (`~/dev/doctrine`). Its environment is more than packages: it has runtime
  state and hooks that the Smut proof could not exercise.
- **Emacs** — the second consumer in step 3, after Doctrine. Out of scope here.

Open questions for the slice (not decided here):

- What a Doctrine environment needs beyond `dev-tools` (hooks, services, offline
  language dependencies) and which of those the consumer layer owns.
- Whether the customisation API is a per-project extras file (step 4) or
  arguments to the consumer's `use_dev_envs` helper.

Depends on SL-022 (done).
