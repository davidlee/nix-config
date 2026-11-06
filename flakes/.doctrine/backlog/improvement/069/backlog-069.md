# IMP-069: Audit and redo _templates: one canonical dev-env producer template

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

`_templates/agents` teaches the retired pattern: per-repo jails (`jailLib`,
`jailPkgs`), `quotientFormFamily`, a `quotient-forms` command, `workspaceDeps`,
and `use agents_dev`. A project should now state only its tools and env;
dev-envs supplies jails, forms, shell and shorthands (SPEC-003). Raised by a
handover from the satan session, 2026-11-06.

Canon: SPEC-003 (producer contract), DEC-111, DEC-112, DEC-113, CHR-030 "Steps
per project", IMP-064. Closest shape: `~/dev/retrograde/flake.nix`.

Preflight findings (2026-11-06):

- The other templates (go, lua, minimal, python, rust, typescript, zig,
  `_templates/_envrc`) are not registered in `flake.nix` and nothing references
  them. `minimal` and `typescript` define no devShell at all. None exports
  `dev-tools`.
- README § Jailed Agents calls the template "the self-contained option", and
  § LLM gateway names it as a client. DEC-062 fixes the template's gateway
  default. All three stop being true.
- `envrc/agents.sh` still serves seven unmigrated repos (bough, forgettable,
  goad, malebolge, panopticon, spec-driver, vk), so it outlives this item; only
  its template pointer changes.
- `agents/README.md` § Updating agents teaches `use agents_dev`.

Open decisions: see the preflight report in the session; record the outcome here.

Related: CHR-030, IMP-064, CHR-026, IMP-007, IMP-047.

Decisions (user, 2026-11-06): DEC-128 (Doctrine via `capsule-tools`), DEC-129
(templates; supersedes DEC-062). `_templates/agents` becomes `_templates/dev-env`.
Follow-up: CHR-031.

Done 2026-11-06.

- `_templates/dev-env` has nixpkgs as its only input, so it dropped flake-parts and
  devshell, unlike retrograde. That is what lets `checks.templates`
  (`templates-test.nix`) evaluate it offline, against dev-envs' own validator.
- Measured from `nix flake init` in a scratch repo with no commits: `dev-tools`
  builds; `type -a doctrine` shows one entry in the dev-envs shell, in
  `jailed-shell` and in the fallback shell; `jcl --version` prints 2.1.310. The
  setup needs `git add flake.nix` before `nix flake lock`. No commit is needed.
- `minimal` works by `nix develop` and by `nix-shell`.
- Found `just test` red: `zmx-new` became a required library argument and three
  test fixtures did not pass it. Fixed here.
