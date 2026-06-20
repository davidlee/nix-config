# pub

Exported flakes which external code may depend on. Try to keep this stable, eh?

## jailed-agents

Sandboxed LLM coding agents using [jail.nix](https://alexdav.id/projects/jail-nix/)
(bubblewrap). Linux only.

### What it provides

- `makeJailedPi`, `makeJailedCrush`, `makeJailedOpencode`, `makeJailedClaude`,
  `makeJailedCodex`, `makeJailedGemini`, `makeJailedZerostack` — pre-configured
  makers for each agent
- `makeJailedAgent` — generic maker for custom agents
- `commonPkgs` — the shared package set available in every jail
- `combinators` — re-exported jail.nix combinators for use in `extraOptions`
- `unjailed` — name→package map of the **bare** (un-jailed) agents, resolved
  from the same eval as the jails. Use it to put agents on the host devShell
  PATH (`with agents.unjailed; [ pi dirge ]`) without separately wiring
  `llm-agents`. Same drvs the jails bundle, so no extra rebuild.

Agent packages come from
[llm-agents.nix](https://github.com/numtide/llm-agents.nix), which callers
provide as a flake input (see usage below). One exception:
[`zerostack`](https://github.com/gi-dellav/zerostack) is built in-tree
(`./zerostack.nix`, `rustPlatform.buildRustPackage`) because it is not yet in
`llm-agents.nix`. The derivation is also exported as `packages.zerostack`.
Evaluation stays lazy — clients that don't call `makeJailedZerostack` never
import the file or fetch the source.

### Sandbox defaults

Every jail gets these **base** options regardless of profile:

- **Workspace mount** at `/workspace/<project>/` — host cwd bind-mounted rw.
- **Timezone**, terminfo, `no-new-session`.
- **Common CLI tools**: git, ripgrep, fd, jq, curl, coreutils, etc.

### Profiles

Profiles control persistence, networking, and git policy. Pass `profile` to
any maker (default: `"specDev"`).

| Profile | Home | Network | Git push | Git identity |
|---|---|---|---|---|
| `specDev` | `agent` (shared, persistent) | yes | blocked | sandboxed (`clanker`) |
| `research` | `agent-research` (separate) | yes | blocked | host |
| `offline` | `agent-offline` (separate) | no | blocked | host |

Override boolean defaults per-call with `blockGitPush` / `sandboxGitIdentity`.

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

Add this flake and `llm-agents.nix` as inputs, then call `mkJailedAgents`
with your own `llm-agents` pin:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    pub.url = "github:davidlee/nix-config?dir=flakes/pub";
    llm-agents.url = "github:numtide/llm-agents.nix";
  };

  outputs = { nixpkgs, flake-utils, pub, llm-agents, ... }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs { inherit system; };
      agents = pub.lib.${system}.mkJailedAgents { inherit llm-agents; };

      # Forward project env into the jail via bwrap --setenv
      envOptions = with agents.combinators; [
        (try-fwd-env "DATABASE_URL")  # forward if set on host
        (set-env "CGO_ENABLED" "0")   # hardcode a value
      ];
    in {
      devShells.default = pkgs.mkShell {
        packages = [
          # your project tools ...
        ] ++ pkgs.lib.optionals pkgs.stdenv.isLinux [
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

If the project has editable dependencies on sibling repos (e.g. a workspace
symlink), use `workspaceDeps` to bind-mount them into the jail:

```nix
(agents.makeJailedClaude {
  profile = "specDev";
  workspaceDeps = [ "/home/you/dev/some-lib" ];
})
```

Each path is mounted at `/workspace/<basename>`, so a symlink like
`./some-lib → ../some-lib` resolves correctly inside the jail.

Because `llm-agents` is pinned in the calling flake, updating agents is a
single `nix flake update llm-agents` — no intermediate commit/push needed.

Then from the project directory:

```
$ nix develop
$ jailed-claude   # or jailed-codex, jailed-gemini, jailed-pi, etc.
```

### Environment variables

bwrap starts with a clean environment — host env vars do **not** pass through
automatically. Use `combinators` via `extraOptions` to forward them:

| Combinator | Effect |
|---|---|
| `set-env "NAME" "value"` | Set a fixed value inside the jail |
| `fwd-env "NAME"` | Forward from host (errors if unset) |
| `try-fwd-env "NAME"` | Forward from host (skipped if unset) |

All combinators are available at `agents.combinators` (re-exported from
jail.nix). See the usage example above.

### Secrets via 1Password (`useOpEnv`)

For online profiles (`specDev`, `research`), `makeJailedAgent` wraps the
sandbox in `op run --env-file=<refs> -- <inner-jail>` by default. The flow:

1. `apiKeyOpRefs` (defaulted in `jailed-agents.nix`, overridable at import
   time) maps env-var names to `op://vault/item/field` references.
2. A nix-store text file is generated from that attrset — refs only, no
   secrets, so world-readable in `/nix/store` is fine.
3. The outer wrapper script execs `op run --env-file=<that-file> -- ...`.
   `op` is resolved from `PATH` so NixOS's setuid wrapper at
   `/run/wrappers/bin/op` is used (the raw store binary can't reach the
   desktop integration socket).
4. `op run` resolves each ref via the 1Password desktop app
   (biometric/CLI unlock) and injects plaintext into the wrapper's env.
5. The bwrap launch then forwards each var into the sandbox via
   `--setenv NAME "${NAME:-}"` raw args.

Result: secrets live only in the bwrap process env for the agent's
lifetime — never on disk, never in the store, never in the host shell
history. The offline profile sets `useOpEnv = false` (no network, no
need).

Override the ref map at import time:

```nix
agents = inputs.pub.lib.${system}.mkJailedAgents {
  inherit (inputs) llm-agents;
  apiKeyOpRefs = {
    OPENROUTER_API_KEY = "op://Work/OpenRouter/credential";
    OPENAI_API_KEY     = "op://Work/OpenAI/credential";
  };
};
```

If `op` is missing from `PATH`, the wrapper bails with a clear message —
build the agent with `useOpEnv = false` to bypass, or install
`_1password-cli` / `_1password-gui` on the host.

Tradeoffs already baked in: `op run --no-masking` is set because masking
corrupts streamed agent output. Agents shouldn't print key values to
stdout regardless.

#### Pre-resolved secrets: `passApiKeysFromEnv`

`op run` resolves refs on every launch. For one-shot interactive use
that's fine — one biometric tap per session is unobtrusive. For an
agent that spawns the jail on a timer (e.g. a 30-minute heartbeat from
Emacs), the biometric prompt becomes per-tick noise.

If the calling process already holds resolved plaintext in memory
(a long-lived Emacs broker, a daemon with its own credential cache,
etc.), drop the outer wrapper and let the caller's env feed the jail:

```nix
satan-jailed-gptel-harness = jailLib.makeJailedAgent {
  name    = "satan-gptel-harness";
  agent   = satanGptelHarness;
  profile = "specDev";
  useOpEnv           = false;  # skip the outer `op run` wrapper
  passApiKeysFromEnv = true;   # keep the bwrap `--setenv VAR "$VAR"` forwarding
};
```

Effect:

- The outer `op run` wrapper is omitted, so launching the jail does not
  call `op` and never prompts 1Password.
- The inner bwrap launcher still ships `--setenv VAR "$VAR"` raw args
  for each entry in `apiKeyOpRefs`, so whatever plaintext the caller has
  set in `process-environment` (or its equivalent) for those names is
  forwarded into the sandbox.
- If the caller fails to set a key, `${VAR:-}` expands to empty and the
  agent simply sees an unset key — same failure mode as a missing env
  var anywhere else, no special handling required.

The caller now owns the credential-cache policy: TTL, clearing on
suspend/lock, refreshing after rotation. The defaults (`useOpEnv =
passApiKeysFromEnv = per-profile`) keep the simple case simple.

### makeJailedAgent options

| Option | Default | Description |
|---|---|---|
| `name` | required | Jail name (binary becomes `jailed-<name>`) |
| `agent` | required | Agent package derivation |
| `profile` | `"specDev"` | Sandbox profile (see table above) |
| `extraPkgs` | `[]` | Additional packages available in the jail |
| `extraOptions` | `[]` | Additional jail.nix combinators |
| `workspaceDeps` | `[]` | Absolute paths to sibling repos; each is bind-mounted at `/workspace/<basename>` |
| `subagents` | `[]` | Sibling agents to expose as depth-guarded `jailed-<name>` wrappers inside the jail. List of names from `agentsByName` (`[ "pi" "dirge" ]`) or the string `"all"`. Nested agents inherit the jail (not re-jailed). |
| `allowSelfAsSubagent` | `false` | Sugar: fold the agent's own `name` into `subagents` (bounded self-recursion) |
| `maxSubagentDepth` | `1` | Maximum nested `jailed-<name>` depth (shared counter across all agents) before the wrapper refuses to recurse |
| `blockGitPush` | per profile | Disable git push via SSH |
| `sandboxGitIdentity` | per profile | Override git author/committer |
| `useOpEnv` | per profile (true for `specDev`/`research`, false for `offline`) | Wrap launch in `op run` to resolve `op://` API key refs at process start |
| `passApiKeysFromEnv` | defaults to `useOpEnv` | Forward each `apiKeyOpRefs` var from the wrapper's env into the jail via `--setenv VAR "$VAR"`. Set independently of `useOpEnv` when the caller pre-resolves secrets (e.g. an Emacs broker with a session-cache) and the outer `op run` would just prompt biometric per launch. |

### Full example

See `examples/go-project/flake.nix`.

## helium

Packaged [Helium](https://github.com/imputnet/helium-linux) browser. Linux only.
