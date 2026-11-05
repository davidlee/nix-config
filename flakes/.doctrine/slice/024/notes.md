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

## Implementation run

Driven by /super-orchestrator; operator approved the plan and asked for sonnet/opus where necessary, pi for research, mechanical edits and code reviews (2026-11-05).

Preflight:

- Forms (`read`, `write`, probed at the seat): no `nix`, `nix-build`, `nix-instantiate`, `bwrap`, `python3`, no store database. `just`, `alejandra`, `statix`, `deadnix`, `jq`, `doctrine`, guarded `git` are present; network works; `write` root is writable. So pi workers edit, format and lint only. Nothing that needs nix runs in a form: that is a form's design, not a gap, and no form change is proposed.
- Host gate: `just gate` from `~/flakes`, in the session's shell (direnv dev-tools on PATH). Baseline green at 495bf973. Host-only: every test, build and real-jail row.
- Commits are host-only and scoped to the phase's paths; new files need `git add`. `path:` flake refs copy untracked files, so tests pass before staging: check `git status -uall -- .` at each commit.
- Plan approval covers plan.md § Notes: launch home (the shipped jail's `agent` home), scratch-config check for empty profiles, the added jail scan. PHASE-04 EN-3 is met by it.
- PHASE-04 VH-1, VH-2 are the operator's; PHASE-05 EN-1 allows them to be outstanding only if the operator defers explicitly.
- Writes in `~/dev/quotient` (PHASE-05 EX-4) are authorised by the plan: doctrine records only, no code, uncommitted unless the seat says otherwise.

## Autonomy log

- PHASE-01: implemented by the sub-orchestrator, no worker: ~40 lines fixed by the design, and the build loop is host-only. Tier: decide.
- PHASE-01: `quotient-in-jail.nix` also returns `etcStoreBinds`, which the design's return list omits but plan.md § Test access needs. Keeps behaviour; flag for audit. Tier: decide.
- PHASE-01: the file takes `{lib, pkgs}` until PHASE-02 needs `combinators`: deadnix would flag it unused. Tier: decide.
- PHASE-01: `agents/README.md` secretEnv row corrected now, not in PHASE-05: the change made it false. Tier: decide.
- PHASE-02: Sonnet capsule-worker wrote tests and code: fake-bwrap contract tests, byte-exact quoting, host build loop (operator's routing). Tier: decide.
- PHASE-02: removed a worker assertion, `refute grep mcp` over bwrap-argv: m, c and p are all nix32 characters, so a store hash could trip it. The entry-word comparison is stronger. Tier: decide.
- PHASE-02: restored the literal key assert (`formArgs.secretEnv`), which also gives PHASE-01 VT-1 its keyword; "exclusive" added to the refusal comment for PHASE-02 VT-1's. Tier: decide.
- PHASE-02: `closure_has` no longer uses `grep -q`: the gate failed once with `tr: write error: Broken pipe`, grep's early exit under pipefail. The existing nixDoctrine check had the same race and now uses the helper. Tier: decide.
- PHASE-02: no `mountLaunchDir` assertion for `quotientServer`, unlike the relay: the design has three, and a jail with workspace deps still has roots under /workspace. Flag for audit. Tier: decide.
- PHASE-03: implemented by the sub-orchestrator, no worker and no pi review: 15 lines fixed by the design, and the lock and build steps are host-only. Tier: decide.
- PHASE-03: VA-1 built the jails against this repo's `dev-tools`, the project `~/flakes/.envrc` names, not the stub: PHASE-04 launches those. Tier: decide.
- PHASE-03: a launch creates an empty `.config/quotient` in the persisted home, bwrap's mount point for the config bind. So PHASE-04 EN-3's "no `.config/quotient`" holds only before the first launch; it is an empty directory, not spike residue. The one from this phase's launch check was removed. Flag for audit. Tier: decide.
- PHASE-04: EX-8's claude half not met as worded: `claude mcp list` ignores `--mcp-config`. No code change: the stream-json init line proves the handshake, and the criterion stays open for the operator. Forced drift in design.md § Verification, for audit. Tier: defer.
- PHASE-04: added codex checks the plan does not name, since `exec` prints no startup line: `mcp list`, a host process watch, `required=true` with a negative control. Tier: decide.
- PHASE-04: write and read delegates ran with cwd in `.doctrine/state/slice/024/proof`, so a delegate's write lands in gitignored state, not the repo. Tier: decide.
- PHASE-04: EX-2's fixture restates the `jail` helper's two `extraOptions` terms in the scratch copy, because `//` would replace them: same net options plus the bind. Tier: decide.
- PHASE-04: EX-2's "26 PASS" read as top-level rows (DEC-127 says identical to host); both logs hold 26 at column 0, 73 in all. design.md wording could say so. Flag for audit. Tier: decide.
- PHASE-04: Sonnet capsule-worker assembled the form-probe fixture (operator's routing); no pi run: every row is host-only. Tier: decide.

## Review passes

After RV-048 (Codex, design facet): no further prose pass is needed. What remains
doubtful is runtime, which another reading cannot settle: `set-argv` registration,
real client startup, the config bind's position beside the relay's options, and a
clean refusal on missing profiles. Execution's tests and real-jail rows probe those.

PHASE-01, pi `review` (deepseek-flash, 22 requests, $0.075). Six findings:

- F1 key on argv (medium): refuted. `nix/form-family.nix:156-180` delivers the secret on a descriptor; the form could not read that source and inferred.
- F2 key test skips the real builder (medium): accepted. The stub is the plan's choice; `quotient-forms` and PHASE-04's delegate rows cover the launcher.
- F3 store binds only grep-checked (medium-low): accepted. The sandbox's /etc holds no store links, so a launch would show nothing; PHASE-04's TLS row proves it.
- F4 `find` stops at a symlinked /etc/ssl (low): accepted. The store directory is still bound, and /etc/ssl is a directory on NixOS.
- F5 stale README row (low): fixed. Its claim about the module header followed from F1, so it falls with it.
- F6 index holds the stub (medium): refuted. `git commit <paths>` commits the worktree.

Negative controls on PHASE-01 (scratch copies, one mutation each), all fail the check: `:-` to `-`; file-only key; no `sort -u`; every path not just the store; store binds before the caller's; no database guard.

PHASE-02, pi `review` (deepseek-flash, 28 requests over two runs, $0.077; the first hit its 25-request ceiling unanswered, so the session was continued). Eight findings:

- F1 `--mcp-config` file not in the jail (high): refuted. jail.nix's runtime closure includes `state.argv` (`bind-nix-store-runtime-closure.nix:51-55`). Now pinned by a closure check on the file.
- F2 `closure_has` reads the wrong closure file (high): refuted. One file per jail (`include-once`).
- F3 profiles source shadowed by the config mount (medium): refuted. The spike's config row saw host profiles through this bind, and bwrap resolves sources on the old root; PHASE-04 repeats it.
- F4 codex entry taken from itself (medium): fixed, `plainCodex` twin.
- F5 refusals do not pin their message (low/medium): accepted. `tryEval` cannot see it; all three read by `nix eval`, each naming `jailed-claude` (EX-2).
- F6 no `mountLaunchDir` assertion (low): accepted, see Autonomy log.
- F7 agent can start quotient under its own policy (low): accepted. design.md § Boundary: protection binds delegates, not the orchestrator.
- F8 broad `quotient` refute on the plain launcher (low): accepted. Not hash-prone, and it is the point of the check.

Both high findings came from reading without jail.nix's source; pi can reach it only through the store path, so a future brief should name it.

Negative controls on PHASE-02 (scratch copies), all fail the check: each of the three assertions removed; policy root changed; `--mcp-config` split in two words; `env_vars` without the URL; every jail registered as claude; a form dropped from the closure; profiles bind writable; config and profiles binds swapped. Moving the options before `profileOptions` passes, as expected: they are runtime args, which follow every static bind wherever they are listed. So "after `profileOptions`" is not what orders them; the argv test is.

EX-3: drvPaths of zsh, claude, codex, pi and a relay jail, all without `quotientServer`, are identical at 22bad1b4 and in the tree.

PHASE-03 VA-1, closure queries. Built with `nix build --no-link --print-out-paths "path:$PWD/dev-envs#packages.x86_64-linux.<jail>" --override-input project "path:$PWD/dev-tools" --override-input agents "path:$PWD/agents" --no-write-lock-file`; each cell is an exact match of the output path in `nix-store --query --requisites <jail>`:

| jail | `quotient-0.6.1` (f9dx6l44…) | `quotient-read` (yilif591…) | `quotient-write` (1akmryjx…) | requisites |
|---|---|---|---|---|
| `jailed-claude` | yes | yes | yes | 303 |
| `jailed-codex` | yes | yes | yes | 304 |
| `jailed-shell` | yes | yes | yes | 302 |
| `jailed-pi` | no | no | no | 277 |
| `jailed-pi-research` | no | no | no | 277 |

`grep -i quotient` over the two pi closures finds nothing. Only `jailed-claude` holds `quotient-mcp.json`; `jailed-codex` registers by argv, and `jailed-shell` registers nothing.

`jailed-pi` and `jailed-pi-research` drvPaths are identical with HEAD's `dev-envs/` (`git archive`) and the tree, so the v0.6.1 move does not reach them: 95jcc7jh…, z6p7s309….

Lock: `nix flake update quotient --flake "path:$PWD/dev-envs"`. The diff is the four lines of node `quotient_2` (rev cd197409 to 1f18594f, the v0.6.1 tag's commit and the root flake's pin); `nixpkgs_8` did not move, and `project` keeps `path = "./stub-project"`. `packages.x86_64-linux.default` at that rev is `quotient-0.6.1`.

`doctrine slice verify-vt` reports PHASE-03 VT-1 UNATTRIBUTABLE before the commit and through ISS-005's prefix: the keywords are present.

## PHASE-04 proof

Jails built with: `JAIL_WORKSPACE_DEPS=$HOME/dev/quotient:$HOME/dev/satan`, `nix build --impure … "path:$PWD/dev-envs#jailed-<j>" --override-input project "path:$PWD/dev-tools" --override-input agents "path:$PWD/agents" --no-write-lock-file`. Links: `.doctrine/state/slice/024/jails/{shell,claude,codex,pi}`. Delegate rows ran `mcp-call.mjs` (real server over stdio) in `jailed-shell`, launched from `~/flakes`, cwd `.doctrine/state/slice/024/proof`, which also holds the raw output (`row-*.out`, gitignored). Launch home `agent`; quotient 0.6.1, claude 2.1.310, codex 0.163.0, quotient checkout 23afd08. Policy in the jail: roots `["/workspace"]`, forms `yilif591…-quotient-read`, `1akmryjx…-quotient-write`.

| row | result |
|---|---|
| EX-1 | pass |
| EX-2 | pass |
| EX-3 | pass |
| EX-4 | pass |
| EX-5 | pass |
| EX-6 | pass |
| EX-7 | pass |
| EX-8 | codex pass; claude **not met as worded**, handshake proved another way |
| EX-9 | pass (observed) |

**EX-1.** `bash /workspace/quotient/scripts/hostile-audit --form "$f" --capability {read,write} --model llm-gateway/deepseek-flash "$PWD" ~/.ha/s ~/.ha/r`, both exit 0, both:

```
attempt:      the delegate ran the probe bash
call:         state=completed termination=stop causes=["stop"]
VERDICT: PASS — audit intact; the child could not reach the path
```

**EX-2.** Fixture by the design's four steps, under the session scratchpad (`fp/`). Probe family built from quotient 23afd08: four attrs (`probe-read`, `probe-write`, `probe-secret-empty`, `probe-protect-file`), 47 lines in `fp/closure`, stand-in copied unedited. The scratch `dev-envs/` differs by one thing: `jailed-shell` restates the `jail` helper's `extraOptions` (`//` would replace them) and appends `add-runtime ''while read -r p; do RUNTIME_ARGS+=(--ro-bind "$p" "$p"); done < "$PWD/fp/closure"''`. `git status --short -- dev-envs` is empty.

```
$ cd …/fp/root && jailed-shell -c 'PATH=/workspace/root/bin:$PATH; command -v nix; bash /workspace/quotient/scripts/form-probe; echo form-probe exit=$?'
/workspace/root/bin/nix
…
form-probe: PASS — every assertion passed
form-probe exit=0
```

"26 PASS" counts lines starting `PASS`, the top-level rows; 47 more sit indented under the read and write form sections. Jail and a fresh host run alike: 26 top-level, 73 in all, 0 FAIL, and the sets of row names are identical (`diff` empty).

**EX-3.** Nested `read`: `state=completed`; `touch: cannot touch './ro-test': Read-only file system`, rc 1; `ls /workspace` shows only `flakes`; `~/.config/quotient` absent in the form. Nested `write`: `write-rc=0`, file present on the host side afterwards; `/workspace/satan/x`: no such file or directory, so the jail's other mounts are out of view.

**EX-4.** One `read` delegate: `http=200` from `curl https://cache.nixos.org/nix-cache-info`; `git ls-remote https://github.com/davidlee/quotient HEAD` gives `1f18594f3a39`, rc 0; `ls /nix/store | wc -l` 204.

**EX-5.** From the jail's shell: `touch` and `>` on `approvals.json`, `touch profiles/x`, append to and `rm` of `profiles/implement.md`, overwrite of `policy.json`: all `Read-only file system`, rc 1. Afterwards `~/.local/share/jail.nix/home/agent/.config/quotient` on the host is still empty (bwrap's mount point).

**EX-6.** `cd /workspace/satan && bash scripts/lib/pi-report-test.sh`: exit 0, full run, `pi-report: 21 passed, 0 failed`, six sections; section 1 "reduces a pi event stream through the default reducer (quotient reduce)" passes all five checks.

**EX-7.** `jailed-pi --version`: `1.4.0`, rc 0. `--list-models`: rc 0, llm-gateway models listed. `grep -ci quotient` over its requisites: 0. Without deps its drvPath is `95jcc7jh…`, the PHASE-03 value.

**EX-8, claude.** `jailed-claude mcp list` does not list `quotient`, and `mcp get quotient` answers `No MCP server named "quotient"`. The design's row assumed `mcp list` reads `--mcp-config`; it reports stored config only (user, project), never `dynamic` servers. Registration itself works: the session's init message shows the real server connected, without a login or a model call:

```
$ jailed-claude -p "say ok" --output-format=stream-json --verbose --max-turns 1
{"mcp_servers":[{"name":"codex","status":"failed","source":"user"},{"name":"doctrine","status":"connected","source":"project"},{"name":"quotient","status":"connected","source":"dynamic"}], …}
result: "Failed to authenticate: OAuth session expired and could not be refreshed", total_cost_usd 0
```

The same message's `tools` list holds: `mcp__quotient__pi_agent mcp__quotient__pi_agent_ack mcp__quotient__pi_agent_cancel mcp__quotient__pi_agent_start mcp__quotient__pi_agent_wait`. `codex` failing is the agent home's own user entry, unrelated. So EX-8's claim, a client-to-server handshake, holds, but by a command the criterion does not name: operator's ruling needed, see Autonomy log.

**EX-8, codex.** `jailed-codex exec --skip-git-repo-check "say ok"`: rc 0, answers `ok`; it says nothing about `quotient` (no startup line, success or failure), and neither does `--json`. Codex is logged in in this home, so these were small model calls (about 5k tokens each). Three further checks: `jailed-codex mcp list` shows `quotient`, its store command, env `LLM_GATEWAY_KEY=*****, LLM_GATEWAY_URL=*****`, `enabled`. A host-side watch during `exec` saw a quotient process whose parent is `codex`, with `HOME LLM_GATEWAY_KEY LLM_GATEWAY_URL PATH` in its environment (names only). `jailed-codex -c mcp_servers.quotient.required=true exec …` runs to `ok`, rc 0, while the same flags on a server that cannot start (`nothere`, negative control) stop with `required MCP servers failed to initialize`, rc 1.

**EX-9.** Scratch config in the jail, `XDG_CONFIG_HOME=/tmp/cfg-{empty,absent}`, `policy.json` copied, `profiles/` empty or missing. Both: the server starts and the call is refused cleanly, naming the directory:

```
{"state":"refused","final":false,"causes":["refused"],"refusal":{"reason":"profile-unknown","detail":"profile \"read\" is not in the start-up snapshot of /tmp/cfg-empty/quotient/profiles"},"result":null}
```

**Design's open items.**

- `--mcp-config` against a project `.mcp.json` of the same name: `--mcp-config` wins. Launched from a scratch directory whose `.mcp.json` names `quotient` and a control, `plantcontrol`, both pointing at a script that exits 7: init shows one `quotient`, `connected`, `dynamic`, and `plantcontrol`, `failed`, `project`. The marker file does not tell which entry ran the script; the status does.
- `path … is not valid` in a form's `stderr.log`: harmless. The same five lines in every run, naming four paths (`hosts`, `etc-nsswitch.conf`, `nss-cacert`, its `-p11kit`). A delegate finds all four present, and `/etc/hosts`, `/etc/nsswitch.conf` and the CA bundle resolve into them: `etc-store-binds` delivers what the deep bind's query cannot.

VH-1, VH-2: outstanding, the operator's. PHASE-04 stays `in_progress`.

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
