## Three paths, live-verified in this jail

| # | Path | What it is | State right now |
|---|---|---|---|
| 1 | `/nix/store/<hash>-doctrine/bin/doctrine` | `craneLib.buildPackage`, exposed as `packages.doctrine` + `packages.default` (`flake.nix:357-375,419`) | **no such store path exists in this jail**; `nix` is absent (`command -v nix` → nothing) |
| 2 | `~/.cargo/bin/doctrine` | legacy `cargo install` default | 2.1 MB, dated Jun 4 — and **not runnable**: `cannot execute: required file not found` (interp missing). Deliberately *not* bound (`flakes/agents/jailed-agents.nix:365-367`) |
| 3 | `/run/doctrine-bin/doctrine` | ro-bind of the host's **`~/.local/share/doctrine/bin`** into the jail | works, `doctrine 0.47.0`; on PATH at `/run/doctrine-bin` |

The "system cargo path" you care about is **not** `~/.cargo/bin` any more — it's `~/.local/share/doctrine/bin`, minted by `just install`:

```
install: web-build
  cargo install --path . --root ~/.local/share/doctrine
```
— `justfile:261-264` ("its bin/ is the directory jails bind (agents flake), so nothing else in ~/.cargo/bin is exposed").

## The bind now lives in the agents flake, not doctrine's

`flakes/agents/jailed-agents.nix:359-382`:

```nix
hostDoctrineDir = "~/.local/share/doctrine/bin";
(try-ro-bind (noescape hostDoctrineDir) "/run/doctrine-bin")
(add-runtime ''mapfile -d "" -t doctrine_binds < <(${elfClosureBinds} ${hostDoctrineDir}/doctrine) …'')
(add-path "/run/doctrine-bin")
```

Three design facts stated there and in doctrine's own flake:
- **directory bind, never file bind** — a file bind pins an inode and `cargo install`'s atomic rename leaves the jail on the deleted one (`IMP-249`); a dir bind shows the new file at once. This supersedes `mem.pattern.env.jail-ro-bind-stale-after-reinstall`'s `ro-bind "${doctrine}/bin/doctrine"` recipe.
- **not over `~/.cargo/bin`** — the jail has a persisted writable `~/.cargo` of its own; binding over it would hide the jail's cargo.
- **`elf-closure-binds`** binds the store paths the host ELF's interpreter + RUNPATH need, discovered *at launch* — so a reinstall by a different toolchain needs a jail relaunch.

Doctrine's side is now a delegation comment, `flake.nix:167-171`: "No doctrine bind here: the agents flake's jail default ro-binds … A directory bind, not a file bind, so a reinstall's atomic rename reaches a running jail (IMP-249)."

## What the pi installer does with these paths

`doctrine install` bakes **`current_exe()`** as an absolute literal into the generated pi extensions (`src/boot.rs:441,2774-2806`; verified `generate_mcp_extension_bakes_exec_path` at `boot.rs:8270`). Governed rule from `SL-195`: **"baked ⟺ gitignored"** — gitignored surfaces (pi `mcp.ts`, `surface.ts`, Claude hooks) stay baked with an absolute exec path; committed surfaces get `${DOCTRINE_BIN:-doctrine}` (`SL-195` scope §"Axis 2 — exec-path bake: dissolved, not a toggle"; same class as `SL-286`'s user-level codex MCP absolute path).

Live consequence, and the sharp edge:

```
.doctrine/state/pi/extensions/mcp.ts:27       const BIN_PATH = "/home/david/.local/share/doctrine/bin/doctrine";
.doctrine/state/pi/extensions/surface.ts:27   (same)
.doctrine/state/pi/extensions/index.ts:8      execSync("/home/david/.local/share/doctrine/bin/doctrine prompt resolve …")
```

In-jail that path is **the jail's own** `~/.local/share/doctrine/bin` — empty. The baked path is dangling, and there is no existence fallback:

```ts
const binPath = typeof BIN_PATH !== 'undefined' ? BIN_PATH : process.env.DOCTRINE_BIN || 'doctrine';
```
(`mcp.ts:339-342`; `typeof` on a baked `const` is always `'true'`, so `DOCTRINE_BIN` is unreachable once baked).

So the host's install dir is visible in-jail **only** at `/run/doctrine-bin`; the two namespaces share the binary but not its path.

## Nix-build caveats for a refactor

- `cleanCargoSource` keeps only `.rs`/`.toml`/`.lock`; a bare crane build ships **asset-incomplete with no compile error**. Everything embedded must be grafted into `srcWithDist` (`flake.nix:334-356`): `plugins/ install/ memory/ templates/ publication/ web/map/dist/`.
- crane must be built with the **same** `rust` binding as the devshell/`just lint`, or toolchain skew flips lint verdicts (`flake.nix:325-334`).
- `checks.quotient-forms` is Linux-only (`flake.nix:385`); `packages.dev-tools` deliberately carries the *crane* doctrine because a microvm guest can't reach the host's cargo install (`flake.nix:412-417`).

## Preflight close

**Confirmed inputs.** Paths 1–3 above; the bind's owner and rationale; the `justfile install` root; the pi bake rule and its no-fallback implementation; the `srcWithDist` graft list.

**Assumptions I'd carry.** (a) `/nix/store` is visible in-jail (evidenced by the PATH), so a store path baked by the installer would resolve in both namespaces — *unverified*, `nix build` is impossible in-jail. (b) The 0.47.0 bound binary vs 0.48.1 in-tree is just relaunch lag, not a defect.

**Open questions / risks.** Whether the refactored flake keeps `~/.local/share/doctrine/bin` as the host install root at all (moving to a store path would make the pi bake both portable and immutable, reconciling `IMP-249` with `SL-195`). `IMP-234` is still open on the installer's `--dev` posture. And `RSK-011` stands: flake edits are unvalidatable in-jail — only `just nix-build` on the host proves it.

**Tension worth naming.** The installer is *path-baking by construction*, and the three namespaces give three different valid answers for "where is doctrine". Whichever binary runs `doctrine install` decides which of the three gets frozen into the gitignored pi surfaces — so the refactor's binary-path decision and the installer's bake decision are the same decision, not two.