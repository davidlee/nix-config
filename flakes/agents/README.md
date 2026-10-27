# agents

Exported flake which external code may depend on. Try to keep this stable, eh?
(Formerly `flakes/pub`, which remains as a re-exporting alias.)

## jailed-agents

Sandboxed LLM coding agents using [jail.nix](https://alexdav.id/projects/jail-nix/)
(bubblewrap). Linux only.

### What it provides

- `makeJailedPi`, `makeJailedCrush`, `makeJailedOpencode`, `makeJailedClaude`,
  `makeJailedCodex`, `makeJailedGemini`, `makeJailedEca`, `makeJailedZerostack`,
  `makeJailedDirge`, `makeJailedZsh` — pre-configured makers, one per
  `agentsByName` entry plus zsh
- `makeJailedAgent` — generic maker for custom agents
- `combinators` — re-exported jail.nix combinators for use in `extraOptions`
- `gatewayClient`, `gatewaySocketOptions` — a jail's `gateway` value for this
  repo's gateway, and its socket-mode options for `extraOptions` (see
  [Gateway mode](#gateway-mode-gateway))
- `quotientFormFamily` — quotient's per-call forms for a gateway client (see
  [quotient forms](#quotient-forms))
- `posture` — the confinement every jail and every form gets, as a function of
  a combinator set (see [quotient forms](#quotient-forms))
- `tryFwdEnv` — `tryFwdEnv c "NAME"`: forward a host variable if set, in a jail
  or a form (see [quotient forms](#quotient-forms))
- `satanMcpOptions` — a satan-mcp client, for `extraOptions`: the socket's
  directory `/run/user/1000/satan/mcp` read-only (never the socket file, whose
  inode satan-mcp replaces on restart), plus `XDG_RUNTIME_DIR` and
  `SATAN_MCP_SOCKET`
- `unjailed` — name→package map of the **bare** (un-jailed) agents, resolved
  from the same eval as the jails. Use it to put agents on the host devShell
  PATH (`with agents.unjailed; [ pi dirge ]`). Same drvs the jails bundle, so no extra rebuild.

Agent packages come from
[llm-agents.nix](https://github.com/numtide/llm-agents.nix), pinned **once, in
this flake** — every consumer (and the host) shares that pin. A caller may pass
its own `llm-agents` to `mkJailedAgents` / `agentsOverlay` to diverge. One exception:
[`zerostack`](https://github.com/gi-dellav/zerostack) is built in-tree
(`./zerostack.nix`, `rustPlatform.buildRustPackage`) because it is not yet in
`llm-agents.nix`. The derivation is also exported as `packages.zerostack`.
Evaluation stays lazy — clients that don't call `makeJailedZerostack` never
import the file or fetch the source.

### Sandbox defaults

Every jail gets these **base** options regardless of profile. Those marked
*posture* are also every quotient form's ([quotient forms](#quotient-forms)):

- **Workspace mount** at `/workspace/<project>/` — host cwd bind-mounted rw,
  after any workspace deps, and the jail starts there. `mountLaunchDir = false` binds nothing and starts
  in `$HOME`, the persisted home.
- **Timezone**, `no-new-session` (*posture*), terminfo (launcher only: a form is
  headless and sets `TERM=dumb`).
- **Common CLI tools**: git, ripgrep, fd, jq, curl, coreutils, etc. (*posture*;
  git is the guarded one unless `guardGit = false`). Also *posture*: the ssh
  push block, the sandboxed git identity, `CLAUDE_CODE_SHELL` and
  `UV_CACHE_DIR`.
- **Host git excludes** (*posture*), read-only. The launcher resolves the host user's
  global excludes file as git does (`core.excludesFile`, else
  `$XDG_CONFIG_HOME/git/ignore`) and mounts it at `~/.config/git/ignore` in
  the jail — git's default excludes path, so no jail gitconfig is touched.
  Agents therefore don't stage what you ignore. Skipped if the file is absent;
  overridden if the jail's own `~/.gitconfig` sets `core.excludesFile`.
- **Host doctrine** (`hostDoctrine`, default on; *posture*), read-only. doctrine's own
  cargo install root, `~/.local/share/doctrine/bin`, holds only doctrine; that
  directory is bound at `/run/doctrine-bin`, which goes on `PATH`. A directory,
  not the file: `cargo install` renames a new file over the old one, and a file
  bind would stay on the deleted one (IMP-249), whereas a directory bind shows
  a reinstall at once. The jail sees only its own closure, so the launcher also
  binds the store paths the binary links against (its interpreter and RUNPATH,
  with their closure), as found at launch: a reinstall built by another
  toolchain needs a relaunch. One binary serves host and jail, so a project
  flake needs no `doctrine` input. If the binary is absent, the jail launches
  without it. Install with `cargo install --path . --root ~/.local/share/doctrine`.

Host audio is intentionally not part of the portable defaults. Opt in from a
machine-specific composition root with jail.nix's `$XDG_RUNTIME_DIR`-aware
`pulse` combinator, plus any host sound file the agent needs:

```nix
audioOptions = with agents.combinators; [
  pulse
  (try-readonly "/path/on/this/host/notification.wav")
];

(agents.makeJailedClaude {
  extraOptions = audioOptions;
})
```

### Profiles

Profiles control persistence, networking, and git policy. Pass `profile` to
any maker (default: `"specDev"`).

| Profile | Home | Network | SSH push | Git identity | Git guard |
|---|---|---|---|---|---|
| `specDev` | `agent` (shared, persistent) | yes | blocked | sandboxed (generic) | on |
| `research` | `agent-research` (separate) | yes | blocked | host | on |
| `offline` | `agent-offline` (separate) | no | blocked | host | on |

`Network` is fixed by the profile: no option overrides it. A gateway jail on
`offline` reaches the gateway in [socket mode](#socket-mode).
`persistedHome = "<name>"` replaces the `Home` column for one jail, so a
caller can keep a jail's state apart from the shared homes. The name is
spliced into a path and the launcher, so it must match
`[A-Za-z0-9][A-Za-z0-9._-]*`; anything else fails evaluation.

Override boolean defaults per-call with `blockSshGitPush` /
`sandboxGitIdentity` / `guardGit`. The SSH guard sets `GIT_SSH_COMMAND` to a
failing helper and clears SSH helpers. It does **not** block HTTPS pushes in networked
profiles, and is a guardrail rather than a security boundary.

The reusable sandbox identity defaults to `Jailed agent
<jailed-agent@localhost>`. Override all four fields when constructing the
library if a composition root wants a host-specific identity:

```nix
agents = inputs.agents.lib.${system}.mkJailedAgents {
  gitIdentity = {
    authorName = "Project agent";
    authorEmail = "agent@example.test";
    committerName = "Project agent";
    committerEmail = "agent@example.test";
  };
};
```

#### Git guard (`guardGit`)

Each jail's git is `guardedGit`: stock git with `bin/git` replaced by
[`git-guard.sh`](./git-guard.sh), which refuses the subcommands that discard
uncommitted work. Everything else execs the real git untouched.

| command | refused |
|---|---|
| `stash` | always, except read-only `list` / `show` |
| `checkout` | with `--`, `-f`/`--force`, `-m`/`--merge` (branch switching passes) |
| `reset` | with `--hard`, `--merge`, `--keep` |
| `clean` | unless `-n` / `--dry-run` |
| `restore` | unless `--source=` |

Bypass for one command with `GIT_GUARD=off git …`; it prints a notice, so the
override shows in the transcript. A speed bump, not a boundary.

Why not `[alias] stash = !false`: git ignores aliases that hide a builtin.

It replaces git rather than shadowing it on PATH, so each jail carries exactly
one git. `guardGit = false` gives plain `pkgs.git`. Probes live in
[`git-guard.test.sh`](./git-guard.test.sh), run by the flake check against the
git a jail actually gets.

#### Sub-agents

Expose sibling agents inside a jail with `subagents` — a list of names
(`[ "pi" "dirge" ]`) or the string `"all"`. Each becomes a depth-guarded
`jailed-<name>` wrapper on the jail's PATH. A nested agent runs inside the
existing bwrap sandbox (it inherits the jail; it is **not** re-jailed), so it
sees the same workspace, network policy, and forwarded API keys.

```nix
(agents.makeJailedClaude {
  profile = "specDev";
  subagents = [ "pi" "dirge" ];   # claude can spawn jailed-pi / jailed-dirge
  maxSubagentDepth = 2;
})
```

`allowSelfAsSubagent = true;` is sugar that folds the agent's own name into
`subagents`. A single `JAILED_AGENT_DEPTH` counter is shared across all
agents, so total nesting depth (e.g. `claude → pi → dirge`) stops once
`maxSubagentDepth` is reached (default: `1`).

### Usage

Add this flake as an input, then call `mkJailedAgents`:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    agents.url = "github:davidlee/nix-config?dir=flakes/agents";
  };

  outputs = inputs @ { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs { inherit system; };
      agents = inputs.agents.lib.${system}.mkJailedAgents { };

      # Forward project env into the jail via bwrap --setenv
      envOptions = with agents.combinators; [
        (try-fwd-env "DATABASE_URL")  # forward if set on host
        (set-env "CGO_ENABLED" "0")   # hardcode a value
      ];
    in {
      devShells.default = pkgs.mkShell {
        packages = [
          # your project tools ...
        ] ++ pkgs.lib.optionals pkgs.stdenv.hostPlatform.isLinux [
          (agents.makeJailedClaude {
            profile = "specDev";
            extraPkgs = with pkgs; [ go gopls ];
            extraOptions = envOptions;
          })
          (agents.makeJailedCodex {
            profile = "specDev";
          })
          (agents.makeJailedGemini {
            profile = "research";
          })
          (agents.makeJailedPi {
            profile = "specDev";
            allowSelfAsSubagent = true;
            maxSubagentDepth = 2;
          })
        ];
      };
    });
}
```

If the project depends on sibling repos (e.g. through a workspace symlink),
bind them into the jail. `workspaceDeps` binds read-only; `workspaceDepsRw`
binds read-write, for the deps the agents must write (DEC-081):

```nix
(agents.makeJailedClaude {
  profile = "specDev";
  workspaceDeps = [ "/home/you/dev/some-lib" ];   # read-only
  workspaceDepsRw = [ "/home/you/notes" ];        # read-write
})
```

```
workspaceDeps   ++ $JAIL_WORKSPACE_DEPS     ─> --ro-bind <src> /workspace/<basename>
workspaceDepsRw ++ $JAIL_WORKSPACE_DEPS_RW  ─> --bind    <src> /workspace/<basename>
host cwd (launch dir), bound last           ─> --bind    $PWD  /workspace/<project>
```

Each path is mounted at `/workspace/<basename>`, so a symlink like
`./some-lib → ../some-lib` resolves correctly inside the jail.
Paths must be absolute but do not need to exist at pure evaluation time.
Trailing slashes are normalized and shell metacharacters remain literal. Two
sources with the same basename fail evaluation instead of silently shadowing
one another, within a list or across the two, so a path cannot be in both.
The launch dir is bound after the deps, so when a dep shares the project's
basename, the project is the one visible (DEC-082).

Before SL-018, `workspaceDeps` bound read-write. A consumer whose agents write
a dep moves it to `workspaceDepsRw` (or `JAIL_WORKSPACE_DEPS_RW`).

For machine-local dependencies, `JAIL_WORKSPACE_DEPS` (read-only) and
`JAIL_WORKSPACE_DEPS_RW` (read-write) may contain newline- or colon-separated
absolute paths. They are read only during impure evaluation and merged with
the static list of the same mode; under pure evaluation an unset or
inaccessible value is simply ignored. `workspaceDepsFromEnv = false` makes a
jail ignore both, so its evaluation no longer reads the environment; the
static lists still bind.

### Updating agents

The pin lives in `agents/flake.lock`. Bump it once:

```
cd ~/flakes/agents && nix flake update llm-agents
```

Projects whose `.envrc` uses `use agents_dev` (template:
`_templates/agents/_envrc`; helper: `envrc/agents.sh`, sourced by the
`.envrc`) read this flake live via `--override-input`, so the bump lands on
their next direnv reload — no per-project lock update. The helper evaluates
impurely only when `JAIL_WORKSPACE_DEPS` or `JAIL_WORKSPACE_DEPS_RW` is set:
those are read with `getEnv`, which a pure evaluation answers with "". The
host picks it up on `nix flake update agents` + `just home-switch`.
Plain `nix develop`, CI, and other machines use the project's committed lock;
refresh that with `nix flake update agents`.

Then from the project directory:

```
$ nix develop
$ jailed-claude   # or jailed-codex, jailed-pi, jailed-pi-research
```

### Environment variables

The jail starts with a clean environment — host env vars do **not** pass
through automatically. Use `combinators` via `extraOptions` to forward them:

| Combinator | Effect |
|---|---|
| `set-env "NAME" "value"` | Set a fixed value inside the jail |
| `fwd-env "NAME"` | Forward from host (errors if unset) |
| `try-fwd-env "NAME"` | Forward from host (skipped if unset) |

All combinators are available at `agents.combinators` (re-exported from
jail.nix). See the usage example above.

**bwrap itself starts with an empty environment**, in every jail. bwrap's
`--clearenv` empties only the agent's environment, not bwrap's own, and bwrap
runs as PID 1 in the jail's pid namespace under the same uid: the agent can
read `/proc/1/environ`. Exec'd with the launching session's environment, bwrap
would hand the agent every key in it. So jail.nix gets a `bwrap` that is
`env -i <bubblewrap>/bin/bwrap "$@"` (`bwrapEmptyEnv` in
`jailed-agents.nix`).

```
launcher (bash, session env) ── expands $VARS, ~, $(…), <(printf …) into argv / FDs
   └─exec─> bwrapEmptyEnv ──exec env -i──> bwrap (environ empty)
                                             └─> agent (--clearenv + --setenv …)
```

This is safe because the launcher has expanded every value before the exec:
`set-env`/`fwd-env` values into argv, the gateway key into the `--args 22`
pipe, which survives the exec. bwrap reads only `HOME`
from its own environment, and only without `--chdir`, which every jail passes.

### Model access

A jail reaches models through the LLM gateway ([Gateway mode](#gateway-mode-gateway))
and no other way: no provider key enters a jail, and nothing in the lib runs
`op` (IMP-051). A jail without `gateway` reaches no model unless its agent
signs in on its own (claude, codex). Provider keys resolved by 1Password
`op run` were removed; IMP-051 names the commit to revert for them.

### Gateway mode (`gateway`)

A jail can hold one key for a local LLM gateway. The
argument is exactly three strings; `gatewayClient` builds it for this repo's
gateway:

```nix
(agents.makeJailedPi {
  gateway = agents.gatewayClient "pi";
  # = {
  #   keyFile      = "$HOME/.config/llm-gateway/keys/pi"; # a shell word, expanded at run time
  #   url          = "http://127.0.0.1:4000/v1";
  #   runDirectory = "/run/llm-gateway";
  # }
})
```

`gatewayClient "<client>"` takes the key file's name; the address comes from
`agents/gateway.nix`. A hand-built value of the same three strings points the
key and URL at any other OpenAI-compatible endpoint that takes a bearer key,
but a jail with pi in it still gets the models listed in `gateway.nix`: the
generated `models.json` always describes this repo's gateway. The gateway itself is described in the top-level
README, § LLM gateway.

Effect:

- The launcher reads `keyFile` with a shell builtin and passes it as
  `LLM_GATEWAY_KEY` over `--args 22` (not argv). `LLM_GATEWAY_URL` is plain
  env.
- The wrapper fails with a message in two cases: the key file is unreadable
  (issue one: `llm-gateway issue … --out <keyFile>`), or the directory the jail
  reaches the gateway through is missing (the gateway is not running;
  `just system-switch`). That directory is `runDirectory`, or in
  [socket mode](#socket-mode) `/run/llm-gateway-client`.

#### Socket mode

A gateway jail whose profile has no network (`offline`) cannot reach
`127.0.0.1:4000`: the relay's listener is in the host's network namespace.
It reaches the gateway through the relay's second listener, a unix socket,
and the URL stays `http://127.0.0.1:4000/v1`.

```
jail (no network)                                          host
 agent ─TCP─> 127.0.0.1:4000 ─> socat ───────────────────> /run/llm-gateway-client/api.sock
              (in-jail forwarder)   ro-bound directory       (user, 0600)
                                                                   │
                       llm-gateway-relay ──> /run/llm-gateway/api.sock ──> llm-gateway
```

- The profile's `network` flag alone selects it. No option sets it.
- The jail binds the directory `/run/llm-gateway-client` read-only, not the
  socket file: a file bind pins one inode and goes stale when the relay
  replaces the socket. The jail cannot replace the socket either.
- `socat` listens on the jail's own `127.0.0.1:4000` and relays each
  connection to the socket. The agent starts only once it is listening, and
  keeps the wrapper's PID, signals and exit status.
- The wrapper's pre-flight checks `/run/llm-gateway-client` rather than
  `runDirectory`. `/run/llm-gateway` is not bound.
- The socket is owned by the user (mode `0600`), so any process of that user
  can open it; the gateway still wants the key (`LLM_GATEWAY_KEY`).

Failures:

| message | meaning |
|---|---|
| `gateway forwarder exited before listening on 127.0.0.1:4000` | `socat` died at start; its own error precedes it (for example address in use) |
| `gateway forwarder not listening on 127.0.0.1:4000 after 2 s` | `socat` is running but never listened |
| `gateway socket mode needs a jail without network (DEC-076)` | an evaluation error: the jail shares the host network namespace, where the forwarder would collide with the relay's own listener |

A jail without `gateway` can take the same path, for a client that holds its
own key file: put `agents.gatewaySocketOptions` in `extraOptions`. There is no
pre-flight then, and the same evaluation error guards a jail with network.

In such a jail the gateway is the only direct network path. What it can spend
is bounded by the key's models and budget. Any other host unix socket bound
into the jail is the jail definition's to audit.

#### pi in gateway mode

pi reads its providers only from `~/.pi/agent/models.json`, which the
persisted home shares with every jail on it. With pi in a gateway jail, a
generated `models.json` from the store is bound read-only over it: one
provider, `llm-gateway`, with the literal `baseUrl` (`url`), `apiKey`
`$LLM_GATEWAY_KEY` (read from the environment per request) and one model per
served alias, selected as `llm-gateway/<alias>`. The name keeps any stored
`auth.json` credential for a built-in provider from matching it.

| jail | bind |
|---|---|
| `gateway` set, pi the agent (`makeJailedPi`, under any `name`, e.g. `pi-research`) | yes |
| `gateway` set, pi a subagent (`subagents = [ "pi" ]`, or `"all"`) | yes |
| `gateway` set, no pi (eca) | no |
| no `gateway` | no: the shared file, unchanged |

A nested pi runs in its parent's jail, so it sees the parent's bind and
key. The file is read-only inside: edit `models.json` from the host or a
non-gateway jail.

**A home should already hold a `models.json`.** Where the persisted home has
none, bwrap creates the bind target as an empty file there, and pi then
warns about it in every later non-gateway jail on that home;
`{"providers":{}}` loads cleanly. The research home's is tracked in the home
repo. The launcher does not seed the file: that would be a host-side write
inside a home the jail can write, which follows any symlink the jail planted.

**Adding a served model** is an entry in `agents/gateway.nix` with `model`,
`provider` and an optional `pi` block: pi gives a custom model no built-in metadata,
so copy `compat`, `thinkingLevelMap` and the limits from pi's built-in entry
for the upstream model, and check it through the gateway (`--thinking off`
gives no reasoning tokens). A served model without `pi` is served but not
listed in pi's `models.json`. The gateway side (price map, key model lists) is in the top-level
README, § LLM gateway.

### quotient forms

`quotientFormFamily` builds a project's quotient form family (the read and
write jails quotient's `pi_agent` runs a delegate in; `quotient help form`). It
calls quotient's `lib.mkFormFamily` with this lib's `pkgs`, `jail-nix` and pi,
and merges the gateway wiring into the caller's own `env`, `secretEnv` and
`piFiles`:

| arg | gets |
|---|---|
| `env` | `LLM_GATEWAY_URL` |
| `secretEnv` | `LLM_GATEWAY_KEY`, read from the client's key file at launch |
| `piFiles` | `models.json` (`piGatewayModels`) |

```nix
formFamily = jailLib.quotientFormFamily {
  inherit quotient;            # the flake or its lib; this flake takes no quotient input
  # client = "pi";             # gateway key, ~/.config/llm-gateway/keys/<client>
  packages = toolchain;        # the rest goes to mkFormFamily as given
};
# formFamily.read, formFamily.write; quotient.lib.checkFormFamily { family = formFamily; … }
```

`network = false` is refused: the form reaches the gateway over TCP.

**Posture.** A form's `options` are the lib's `posture`, then the caller's own
`options` (IMP-052). The posture is the confinement half of
[Sandbox defaults](#sandbox-defaults): host doctrine, host git excludes, the
ssh push block, the sandboxed git identity, guarded git and the common tools.
`makeJailedAgent` applies the same function to its own combinators, so the
two cannot drift. `postureFlags` sets its flags; a form defaults
`sandboxGitIdentity` to `true` (a form runs a delegate):

```nix
formFamily = jailLib.quotientFormFamily {
  inherit quotient;
  postureFlags.hostDoctrine = false;           # sandboxGitIdentity, blockSshGitPush, guardGit too
  options = c: projectOptions c;               # the project half, after the posture
};
```

- **Write the project half once**, as `c: [ … ]`, and pass it to both
  builders: `options = projectOptions` here, `extraOptions = projectOptions
  jailLib.combinators` in a jail. That holds because both take the combinator
  set of this lib's jail.nix pin; go through `quotientFormFamily`, not
  `mkFormFamily` with another pin.
- **PATH**: quotient adds `packages` before `options`, so the posture's tools
  (guarded git included) come before a form's `packages`. A project that needs
  its own build of a common tool adds it with `c.add-pkg-deps` in `options`.
- **The bwrap line stays plain words.** quotient's check refuses a process
  substitution or `$(…)` on it, so the posture's launch-time binds (doctrine's
  closure, the excludes file) are `add-runtime` code that appends to
  `RUNTIME_ARGS`. The check lists them as runtime binds it cannot see.
  The project half follows the same rule: forward a host variable with
  `jailLib.tryFwdEnv c "NAME"`, not jail.nix's `try-fwd-env`, whose
  `${NAME+…}` the check refuses.

### makeJailedAgent options

| Option | Default | Description |
|---|---|---|
| `name` | required | Jail name (binary becomes `jailed-<name>`) |
| `agent` | required | Agent package derivation |
| `profile` | `"specDev"` | Sandbox profile (see table above) |
| `extraPkgs` | `[]` | Additional packages available in the jail |
| `extraOptions` | `[]` | Additional jail.nix combinators |
| `workspaceDeps` | `[]` | Absolute paths to sibling repos; each is bound read-only at `/workspace/<basename>` |
| `workspaceDepsRw` | `[]` | As `workspaceDeps`, bound read-write |
| `workspaceDepsFromEnv` | `true` | Merge `JAIL_WORKSPACE_DEPS` into `workspaceDeps` and `JAIL_WORKSPACE_DEPS_RW` into `workspaceDepsRw` (impure evaluation). `false`: ignore both |
| `mountLaunchDir` | `true` | Bind the host cwd at `/workspace/<project>` and start there. `false`: bind nothing, start in `$HOME` |
| `persistedHome` | `null` | Name of the persisted home (`[A-Za-z0-9][A-Za-z0-9._-]*`). `null`: the profile's |
| `subagents` | `[]` | Sibling agents to expose as depth-guarded `jailed-<name>` wrappers inside the jail. List of names from `agentsByName` (`[ "pi" "dirge" ]`) or the string `"all"`. Nested agents inherit the jail (not re-jailed). |
| `allowSelfAsSubagent` | `false` | Sugar: fold the agent's own `name` into `subagents` (bounded self-recursion) |
| `maxSubagentDepth` | `1` | Maximum nested `jailed-<name>` depth (shared counter across all agents) before the wrapper refuses to recurse |
| `blockSshGitPush` | `true` | Disable Git pushes over SSH. HTTPS is unaffected. |
| `sandboxGitIdentity` | per profile (true for `specDev` only) | Override git author/committer |
| `guardGit` | `true` | Refuse work-discarding git subcommands (see [Git guard](#git-guard-guardgit)) |
| `hostDoctrine` | `true` | Bind the host's doctrine install root (`~/.local/share/doctrine/bin`), and the store paths it links against, read-only (see [Sandbox defaults](#sandbox-defaults)) |
| `gateway` | `null` | `{ keyFile; url; runDirectory; }`: run against an LLM gateway, the only model access (see [Gateway mode](#gateway-mode-gateway)). `gatewayClient "<client>"` builds it; with pi in the jail, binds the generated `models.json`. A profile without network uses [socket mode](#socket-mode) |

## helium

Packaged [Helium](https://github.com/imputnet/helium-linux) browser. Linux only.
