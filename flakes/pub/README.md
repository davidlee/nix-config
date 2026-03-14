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

Each jailed agent gets:

- **Persistent shared home** at `~/.local/share/jail.nix/home/agent/` (host path).
  All agents share this home — config files, shell history, etc. persist across
  projects and invocations.
- **Workspace mount** at `/workspace/<project>/` — the host cwd is bind-mounted
  read-write and the jail starts there.
- **Network access**, timezone, terminfo.
- **Git push blocked** (SSH disabled, no auth sock). Local commits work and are
  attributed to `clanker <clanker@local>`.
- **Common CLI tools**: git, ripgrep, fd, jq, curl, coreutils, etc.

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
            extraPkgs = with pkgs; [ go gopls ];
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
| `extraPkgs` | `[]` | Additional packages available in the jail |
| `extraOptions` | `[]` | Additional jail.nix combinators |
| `blockGitPush` | `true` | Disable git push via SSH |
| `sandboxGitIdentity` | `true` | Override git author/committer |

### Full example

See `examples/go-project/flake.nix`.

## helium

Packaged [Helium](https://github.com/imputnet/helium-linux) browser. Linux only.
