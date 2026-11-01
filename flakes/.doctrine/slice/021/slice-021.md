# Tangled knot on Sleipnir behind Tailscale Funnel

## Context

[Tangled](https://tangled.org) is a git forge on the AT Protocol (atproto).
A **knot** is its self-hosted git server: it stores the repos and serves them
over HTTP (XRPC API) and SSH. The Tangled web app (the *appview*) reaches the
knot by HTTPS at the knot's hostname, which is the knot's permanent identity.

Upstream ships a NixOS module (evidence: tangled.org/docs/self-hosting/knot,
read 2026-10-31):

```nix
inputs.tangled.url = "git+https://tangled.org/did:plc:j5hmlfdrwkvtxm7cjmu7j2is";
# module: tangled.nixosModules.knot-rs
services.tangled.knot-rs = {
  enable = true;
  environmentFile = "/etc/knot/knot.env";        # KNOT_MASTER_KEY=…
  settings.server = { hostname = "…"; admins = [ "did:plc:…" ]; };
  settings.atproto.plc_directory = "https://plc.directory";
};
# HTTP on 127.0.0.1:5555; SSH (clone/push) on 2222
```

## Scope & Objectives

User decisions, 2026-10-31:

- **Exposure: Tailscale Funnel.** Funnel (free on all plans) publishes
  `https://<machine>.<tailnet>.ts.net` → `127.0.0.1:5555`. No router change,
  home IP not exposed. Funnel carries TLS only, so knot SSH (2222) is reachable
  on the tailnet (`tailscale0`) only: push from own devices; public clone over
  HTTPS.
- **Identifiers: Public.** The knot hostname (the ts.net name) and the owner's
  DID are committed. POL-001's table gains them as Public examples; this
  reclassifies this one tailnet name, the rest of the tailnet's naming stays
  Private.
- **Master key: 1Password + systemd credentials**, the LLM gateway's pattern
  (`just gateway-credentials`): encrypted with host+TPM2 under
  `/etc/credstore.encrypted`; 1Password holds the backup.

Deliverables:

```
flake.nix  ── input tangled ──> features/<area>.nix: record "knot"
                                   nixos half: knot-rs module, funnel unit,
                                               firewall 2222 on tailscale0,
                                               credential → environmentFile
                                   requires = [ "net.tailscale" ]
hosts/Sleipnir/features.nix ── selects it
justfile ── knot-credentials recipe
README ── § Tangled knot (operations: first run, register, backup)
```

## Non-Goals

- Public SSH push (port-forward, custom domain): rejected for this slice.
- A spindle (Tangled CI runner).
- Migrating existing repos onto the knot. When repos do go on it, only
  GitHub-public ones may (DEC-098: Tangled has no private repos); a
  documented rule, no automation.
- Other hosts.

## Summary

One off-by-default feature, selected by Sleipnir, running the upstream knot
module behind Funnel, with its master key as a systemd credential.

## Risks, assumptions, open questions

- **A1** The upstream module accepts the master key through
  `environmentFile` or a `LoadCredential`-compatible path — check in research.
- **A2** Funnel's TLS-terminating reverse proxy suffices for the appview's
  XRPC calls (and any websocket/event stream the knot serves).
- **R1** The hostname is the knot's identity: a tailnet or machine rename
  breaks it. Accepted.
- **R2** Funnel bandwidth caps are unpublished; fine for personal use.
- **OQ-1** Which feature area: `services` (beside ssh/webserver) or `dev.scm`?
- **OQ-2** How the funnel is declared: `services.tailscale.serve`-style
  option if nixpkgs has one, else a oneshot unit running `tailscale funnel
  --bg`.
- **OQ-3** The upstream input's own nixpkgs: follow ours or not.
- **OQ-4** Coverage: Sleipnir selects it, so no coverage target needed.

## Verification / closure intent

- `just test`, `just coverage` green; lint/format clean.
- After switch: `curl https://<host>/xrpc/_health` succeeds from off-tailnet;
  knot registered in appview Settings → Knots; a repo created and pushed over
  SSH 2222 from the tailnet. (VH: user-run steps.)
- POL-001 table updated; README section written.

## Follow-Ups
