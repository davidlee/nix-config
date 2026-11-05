# ISS-026: pi-report trusts the jail's quotient shim, which does not reduce

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

`satan:scripts/lib/pi-report-test.sh` passes 9 of 9 on the host and 6 of 9 in a
dev-envs `jailed-shell` (2026-11-05). This is the only red in satan's `just
check` in a jail.

Evidence: in the jail `quotient` resolves to `quotient-jail-shim`, so the
test's `command -v quotient` is true and it runs the reducer path. The output
lacks the tool call, the `## Result` section and the `transcript=` status.

Confirmed 2026-11-05 (below). `pi_report` falls back only when the reducer is
not on PATH, and the shim is on PATH, so a report in a jail loses its content
with no error.

Found during IMP-063.

**Blocked on IMP-066.** The operator held code changes until the relay's purpose
is settled (2026-11-05). The fix's shape depends on its question 6.

## What the test covers

Section 1 of the test checks `pi_report`'s default path through the reducer. Its
guard asks only "is there a reducer?". It knows nothing of jails, delegation or
MCP, and uses none of them. It fails because one name, `quotient`, is two things:
bare, an MCP server that must be on the host; `quotient reduce`, a pure
file-to-file function with no host need. The test is not wrong. Do not change its
guard.

## Root cause

`agents/quotient-relay.nix`, `shim`: it ignores its arguments and always runs
`exec socat STDIO UNIX-CONNECT:/run/quotient/mcp.sock`.

## Evidence (2026-11-05, satan at 779d4392, `jailed-shell`)

| run, same stream | exit | stdout | stderr |
|---|---|---|---|
| host `quotient reduce -v --out D F` (0.6.1) | 0 | 89 B transcript | status with `transcript=` |
| jail, stdin `/dev/null` | **0** | **0 B** | **0 B** |
| jail, stdin an open idle pipe | **hangs**; `timeout` gives 124 | 0 B | socat's signal warning |
| jail, `--version`, `help` | 0 | 0 B | 0 B |

- Test in the jail: 6 of 9, the three failures as reported.
- `quotient reduce` exits 0 completed, 1 failed or incomplete, 2 usage. An empty
  or junk stream exits 1 and still prints 64 B.
- Pinned 0.6.0 `reduce` works under `bwrap` with only its closure, no network and
  an empty environment. The host's store path is not visible in the jail.
- Refusing arguments is safe for MCP: `satan/.mcp.json` registers a bare
  `quotient`, and the relay's server runs it bare.
- Inference: a jailed spawn loses its report (all three spawn scripts call
  `pi_report`). No real jailed spawn was run. Whether the hang occurs depends on
  the caller's stdin, unchecked.

A second defect is in satan and independent: `pi_report` swallows every reducer
failure (satan:ISS-062).

## Fix options

The shim should refuse what it cannot do in every case. The question is how
`reduce` gets served in a jail.

| option | test passes unchanged | cost |
|---|---|---|
| A. shim runs `reduce` locally; `mkJailedAgents` takes an optional reducer, dev-envs passes its pin | yes | a satan-only need built into every dev-envs jail; 198 MB closure; reducer follows the dev-envs pin |
| B. shim refuses; satan sets `PI_REDUCE` to its own pinned quotient through `passthru.devEnv.env` | yes, if it reaches the jail (**untested**) | satan's `CLAUDE.md` recipe `quotient reduce` needs a caveat |
| C. shim refuses, nothing else | no: the fallback tail lacks the tested output | the guard would have to change: forbidden |
| D. relay `reduce` to the host | yes | rejected: the host would parse jail data |

Preferred before the hold: B. If IMP-066 puts a real quotient in the jail, `reduce`
works there and this item may shrink to the refusal.

B needs a scratch check that the store path's closure reaches the jail. Do not
add quotient to satan's `devToolPkgs`: it could shadow the shim on PATH, and the
jail's MCP would stop reaching host policy and forms.

## Done means

`pi-report-test.sh` passes on the host and in the jail, satan's `just check` is
green in the jail (corpus tests skip unless `JAIL_WORKSPACE_DEPS_RW` is set), red
first, one commit per repo.
