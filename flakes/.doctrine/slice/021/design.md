<!-- doctrine:section sec-1 -->
## Overview

One off-by-default feature record, `services.knot`, runs Tangled's knot (its self-hosted git server) on Sleipnir. Upstream's NixOS module does the work; the record adds three things the module lacks: the master key as a systemd credential (DEC-095), a Funnel publishing the HTTP surface (DEC-096), and SSH confined to the tailnet.

```
internet ──https──> Tailscale Funnel (sleipnir.bandicoot-sunfish.ts.net:443, TLS ends here)
                        │ tailscaled, knot-funnel.service
                        ▼
                 127.0.0.1:5555  knot-rs.service  ──> /var/lib/knot/{repos,lfs,sealed-keys,ssh_host_key}
                 [::]:2222 ssh ◄── firewall: tailscale0 only ◄── own devices (push)
                        ▲
   /etc/credstore.encrypted/knot.master-key ──LoadCredentialEncrypted──> wrapper ──KNOT_MASTER_KEY──> knot-server
        ▲
   just knot-credentials  ◄── op://SLEIPNIR_CREDENTIALS/KNOT_MASTER_KEY/credential
```

Visibility: Tangled has no private repos, so only GitHub-public repos go on the knot (DEC-098). Documented, not enforced.
<!-- doctrine:section sec-2 -->
## Feature record

`features/services.nix` gains a record `knot`: `platforms = lib.platforms.linux`, `requires = ["net.tailscale"]`, nixos half only. It imports `inputs.tangled.nixosModules.knot-rs`, the precedent being `features/attention.nix:76` importing a flake input's module. Sleipnir selects it in `hosts/Sleipnir/features.nix` under `feature.services`; `requires` never selects (ADR-001), and Sleipnir already has `net.tailscale` from `personal-linux`.

Settings:

| key | value |
|---|---|
| `server.hostname` | `sleipnir.bandicoot-sunfish.ts.net` (Public by user decision, POL-001 table updated) |
| `server.admins` | `[ <owner DID> ]`, supplied by the user at implementation |
| `contact.email` | `dav@davlee.com` (personal commit email, Public) |
| `lfs.store_path` | `/var/lib/knot/lfs` |
| `atproto.plc_directory` | `https://plc.directory` |
| `listen_addr`, `ssh_listen_addr` | upstream defaults: `127.0.0.1:5555`, `[::]:2222` |
| `xrpc.trusted_proxy_header` | null (unverified that Funnel sets one; forgeable otherwise) |

`openFirewall = false`; the record opens `networking.firewall.interfaces.tailscale0.allowedTCPPorts = [2222]` itself (ADR-004: the record owns its ports). Port 22 stays sshd's.

Flake input: `tangled.url = "git+https://tangled.org/@tangled.org/core"`, no nixpkgs follow (DEC-097).
<!-- doctrine:section sec-3 -->
## Master key (DEC-095)

The knot's master key unseals its signing key; losing it loses control of the repos, so 1Password holds the only plaintext copy.

- **Store:** `/etc/credstore.encrypted/knot.master-key`, encrypted `--with-key=host+tpm2`, `--name=master-key`. The directory is the gateway's (`features/agents/gateway.nix:28`).
- **Writer:** `just knot-credentials`: `op read op://SLEIPNIR_CREDENTIALS/KNOT_MASTER_KEY/credential | sudo systemd-creds encrypt --with-key=host+tpm2 --name=master-key - <store>`, then `systemctl restart knot-rs`. The secret travels on a pipe, never argv. It refuses an empty value, and a value that is not 32 bytes of base64, because the 1Password item currently holds a placeholder.
- **Reader:** `systemd.services.knot-rs.serviceConfig`: `LoadCredentialEncrypted = "master-key:<store>"`; `ExecStart = mkForce <wrapper>`. The wrapper (`pkgs.writeShellScript`) reads `$CREDENTIALS_DIRECTORY/master-key` into `KNOT_MASTER_KEY` (the name from `settings.secrets.master_key_env`), then `exec`s `lib.getExe cfg.package --config /etc/knot/config.toml`, upstream's ExecStart verbatim.
- `environmentFile = "/dev/null"` satisfies upstream's non-null assertion and sets nothing.

Without the credential, systemd refuses the unit at credential setup (`243/CREDENTIALS`), as the gateway's does on first run. That is the first-run state, documented, not a defect.

Coupling: the wrapper repeats upstream's ExecStart. A test pins it (§ Verification) so an upstream change shows up red.
<!-- doctrine:section sec-4 -->
## Funnel (DEC-096)

`systemd.services.knot-funnel`: `Type=oneshot`, `RemainAfterExit=true`, `after`/`wants` `tailscaled.service` and `knot-rs.service`, `wantedBy = multi-user.target`.

- `ExecStart`: `tailscale funnel --bg --https=443 http://127.0.0.1:5555`
- `ExecStop`: `tailscale funnel --https=443 off`

The Funnel config persists in tailscaled's state, so `ExecStop` matters: turning the feature off stops the unit at switch, which unpublishes the knot. Port 443 on the ts.net name belongs to the knot.

Prerequisite: the tailnet policy grants this node the `funnel` attribute. It was granted 2026-10-31 (evidence: `tailscale status --json` shows `funnel` and `funnel-ports?ports=443,8443,10000`).
<!-- doctrine:section sec-5 -->
## Operations (README § Tangled knot)

A README section, written like § LLM gateway:

1. Generate the key once: `openssl rand -base64 32`, stored as `KNOT_MASTER_KEY` in vault `SLEIPNIR_CREDENTIALS`, replacing the placeholder. Back up 1Password; the key is unrecoverable.
2. `just system-switch`: `knot-rs` fails with 243/CREDENTIALS (expected).
3. `just knot-credentials`: encrypts the key and restarts the knot.
4. `curl https://sleipnir.bandicoot-sunfish.ts.net/xrpc/_health` from off the tailnet.
5. In the Tangled web app, Settings → Knots: add the hostname.
6. Push over `ssh://git@sleipnir.bandicoot-sunfish.ts.net:2222/…`, from the tailnet only.

Also: the visibility rule (DEC-098); what the knot keeps in `/var/lib/knot`; recovery (the sealed key is regenerable only with the master key); and that a tailnet or machine rename breaks the knot's identity.

POL-001: the Public row gains "the knot's ts.net hostname and the owner's atproto DID". That edit goes through a revision (REV), since POL-001 is governance.
<!-- doctrine:section sec-6 -->
## Code impact

| path | change |
|---|---|
| `flake.nix`, `flake.lock` | input `tangled` |
| `features/services.nix` | record `knot` |
| `features/services/knot-test.nix` | eval tests (new) |
| `perSystem.nix` | `checks.<system>.knot` (Linux) |
| `justfile` | `knot-credentials` recipe; `test` builds `checks.knot` |
| `hosts/Sleipnir/features.nix` | `feature.services.knot.enable = true` |
| `README.md` | § Tangled knot; feature tree line for `services.nix` |
| POL-001 | Public row, via REV |

The credential-writing logic is a few lines of just recipe. It does not reuse the gateway's Python `credentials` verb, which is provider-specific. A shared credstore writer is a candidate follow-up if a third consumer appears.
<!-- doctrine:section sec-7 -->
## Verification

**VT** `checks.<system>.knot`: `lib.runTests` over a minimal `nixosSystem` holding only the knot record's nixos module plus `services.tailscale.enable`. It asserts:

- 2222 is in `networking.firewall.interfaces.tailscale0.allowedTCPPorts`, and not in the global `allowedTCPPorts`;
- `knot-rs` carries `LoadCredentialEncrypted` naming `master-key` and the credstore path;
- `knot-rs`'s ExecStart is the wrapper, and the wrapper's `exec` line equals upstream's ExecStart (the coupling pin);
- `knot-funnel`'s ExecStart and ExecStop target `127.0.0.1:5555` on 443.

**VT** the wrapper: a runCommand test with a fixture `CREDENTIALS_DIRECTORY` and a stub binary. The stub sees `KNOT_MASTER_KEY` set, and the wrapper exits non-zero when the credential file is missing.

**VT** `just coverage` and `just drvs` (the drvPath snapshot gate): Sleipnir evaluates; no other host's drvPath changes.

**VH** (user, after switch): health curl from off the tailnet; knot registered in the web app; a public repo pushed over 2222 from the tailnet.
