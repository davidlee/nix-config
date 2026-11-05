# Notes SL-024: In-jail quotient for dev-envs: real server in the jail, delegates under the nested form family

Durable per-slice scratchpad — tracked in git. The place to lift anything from a
disposable phase sheet (`.doctrine/state/.../phase-NN.md`) that must survive
`rm -rf` before the slice close-out audit harvests it.

## Harvest
<!-- single-copy: updated in place each harvest; ids only, never restated content -->
fresh-as-of: 2026-11-05 · plan drafted, design locked rev 30 · 6ef16e4a

### Produced
- SL-024 design locked (rev 30, DEC-123..127, RV-048 done); plan.toml, plan.md and PHASE-01..05 sheets authored. No repo code changed. Uncommitted: slice files, notes, slug symlink, memory, DEC-123..127 and their slug symlinks, RV-048, design snapshot (operator has not asked for a commit)
- owed: a quotient backlog item for form-probe's prebuilt-family mode (DEC-127); a note on quotient:DEC-071 point 3 (DEC-126)

### Learned
- mem.fact.quotient.nested-form-in-jail — store-DB gaps, MCP client quirks

### Open
- plan approval owed, including plan.md § Notes' launch-home departure; then `doctrine slice status 24 ready` and `/phase-plan` PHASE-01

## Review passes

After RV-048 (Codex, design facet): no further prose pass is needed. What remains
doubtful is runtime, which another reading cannot settle: `set-argv` registration,
real client startup, the config bind's position beside the relay's options, and a
clean refusal on missing profiles. Execution's tests and real-jail rows probe those.

## Design triage (2026-11-05)

Constraining governance: quotient:DEC-071, DEC-122, SPEC-003, POL-001. Open
questions, shaping decisions: the design run's inq-1..5.

Operator's direction:

- Registered by default in `jailed-claude` and `jailed-codex`; `jailed-shell`
  carries the closure unregistered; `jailed-pi*` unchanged. Library argument off
  by default. (Reply "1 + codex"; reading confirmed by "agreed".)
- Declined binding all of `/nix/store` into a form.
- Profiles: the host's directory bound read-only, not a store copy or a move.
- form-probe's stand-in run is accepted as proof; raise the rest in quotient.

Risks: a full delegate call from a logged-in claude or codex is unproven (probe
home has no login). Key or pin changes give dev-envs forms new store paths, so
each project needs `quotient allow` again. Delegates rooted at `/workspace/flakes`
get no outer git.

## Probe evidence (real `jailed-shell`, satan family, quotient v0.6.1)

Outlives `research/`, which is gitignored. Spike shape: `research/raw/spike-*.diff`.

| check | result |
|---|---|
| closure via `extraPkgs` | quotient, forms and bwrap present; nothing bound by hand |
| key `${{LLM_GATEWAY_KEY:-$(< keyFile)}}` | delegates reached the gateway |
| `read` nested | completed; root `EROFS`; only the root under `/workspace`; config invisible; runs masked |
| `write` nested | root writable; other jail mounts not in view |
| direct TLS | `curl: (60)` unfixed; `http=200` with the `/etc` binds; HTTPS `git ls-remote` works |
| `/etc` binds, no database | form sees 687 store entries (whole-store bind: 1148, declined) |
| config | read-only store dir plus host `profiles/` bound onto it: delegate ran, `approvals.json` and profile writes refused |
| `checkFormFamily` | passes with the binds |
| hostile-audit `read`, `write` | PASS, delegate attempted the write, with the `/etc` binds |
| form-probe | exit 0, 26 PASS, same as host; `nix` stand-in replays host build and eval answers; its family lacks the `/etc` binds |
| satan `pi-report-test.sh` | section 1 passed; full run not captured (probe's `head`) |
| MCP child env | claude: key present. codex: absent until `env_vars` names it |
