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
Enable self-recursive sub-agents with `allowSelfAsSubagent = true;`; nested
invocations stop once `maxSubagentDepth` is reached (default: `1`).

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

### makeJailedAgent options

| Option | Default | Description |
|---|---|---|
| `name` | required | Jail name (binary becomes `jailed-<name>`) |
| `agent` | required | Agent package derivation |
| `profile` | `"specDev"` | Sandbox profile (see table above) |
| `extraPkgs` | `[]` | Additional packages available in the jail |
| `extraOptions` | `[]` | Additional jail.nix combinators |
| `workspaceDeps` | `[]` | Absolute paths to sibling repos; each is bind-mounted at `/workspace/<basename>` |
| `allowSelfAsSubagent` | `false` | Expose `jailed-<name>` inside the jail for bounded self-recursive sub-agents |
| `maxSubagentDepth` | `1` | Maximum nested `jailed-<name>` depth before the helper refuses to recurse |
| `blockGitPush` | per profile | Disable git push via SSH |
| `sandboxGitIdentity` | per profile | Override git author/committer |
| `useOpEnv` | per profile (true for `specDev`/`research`, false for `offline`) | Wrap launch in `op run` to resolve `op://` API key refs at process start |

### Full example

See `examples/go-project/flake.nix`.

## helium

Packaged [Helium](https://github.com/imputnet/helium-linux) browser. Linux only.
