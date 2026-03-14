# pub

Exported flakes which external code may depend on. Try to keep this stable, eh?

## jailed-agents

Sandboxed LLM coding agents using [jail.nix](https://alexdav.id/projects/jail-nix/)
(bubblewrap). Linux only.

### What it provides

- `makeJailedPi`, `makeJailedCrush`, `makeJailedOpencode` — pre-configured
  makers for each agent
- `makeJailedAgent` — generic maker for custom agents
- `commonPkgs` — the shared package set available in every jail

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

### Usage

Add this flake as an input and call the makers from your devShell:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    jailed-agents.url = "github:davidlee/nix-config?dir=flakes/pub";
  };

  outputs = { nixpkgs, flake-utils, jailed-agents, ... }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs { inherit system; };
      agents = jailed-agents.lib.${system}.jailed-agents;
    in {
      devShells.default = pkgs.mkShell {
        packages = [
          # your project tools ...
        ] ++ pkgs.lib.optionals pkgs.stdenv.isLinux [
          (agents.makeJailedPi {
            profile = "specDev";
            extraPkgs = with pkgs; [ go gopls ];
          })
          (agents.makeJailedPi {
            profile = "research";
          })
        ];
      };
    });
}
```

Then from the project directory:

```
$ nix develop
$ jailed-pi
```

### makeJailedAgent options

| Option | Default | Description |
|---|---|---|
| `name` | required | Jail name (binary becomes `jailed-<name>`) |
| `agent` | required | Agent package derivation |
| `profile` | `"specDev"` | Sandbox profile (see table above) |
| `extraPkgs` | `[]` | Additional packages available in the jail |
| `extraOptions` | `[]` | Additional jail.nix combinators |
| `blockGitPush` | per profile | Disable git push via SSH |
| `sandboxGitIdentity` | per profile | Override git author/committer |

### Full example

See `examples/go-project/flake.nix`.

## helium

Packaged [Helium](https://github.com/imputnet/helium-linux) browser. Linux only.
