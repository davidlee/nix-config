# pub

Exported flakes which external code may depend on. Try to keep this stable, eh?

## jailed-agents

Sandboxed LLM coding agents using [jail.nix](https://alexdav.id/projects/jail-nix/)
(bubblewrap). Linux only.

### What it provides

- `makeJailedPi`, `makeJailedCrush`, `makeJailedOpencode`, `makeJailedClaude`,
  `makeJailedCodex`, `makeJailedGemini` — pre-configured makers for each agent
- `makeJailedAgent` — generic maker for custom agents
- `commonPkgs` — the shared package set available in every jail
- `combinators` — re-exported jail.nix combinators for use in `extraOptions`

Agent packages come from
[llm-agents.nix](https://github.com/numtide/llm-agents.nix), which callers
provide as a flake input (see usage below).

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

### Full example

See `examples/go-project/flake.nix`.

## helium

Packaged [Helium](https://github.com/imputnet/helium-linux) browser. Linux only.
