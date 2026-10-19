# REV REV-012 — reconcile SL-015

Revision — a pending revise-intent against authored governance/spec
truth. The structured `[[change]]` payload lives in the sister `revision-NNN.toml`;
this prose companion carries the rationale and the free-text before/after excerpts
for prose-body section edits.

## Rationale

<!-- Why this revision: what authored truth needs to change and why, the scope of
     the staged delta, and (for ADR/POL/STD/prose rows) the before/after excerpts
     the structured payload only labels. Seeded at `revision new`. -->

SL-015 shipped a second reach path to the gateway (DEC-075, DEC-076, DEC-077);
SPEC-001's client contract and perimeter describe only `127.0.0.1:4000`.

### SPEC-001 § Client contract — Reach (append after the existing paragraph)

> A jail without network (bwrap `--unshare-net`) reaches the same URL through
> an in-jail forwarder to `/run/llm-gateway-client/api.sock` (socket mode,
> DEC-076); the client sees no difference. Authentication is the same bearer
> key; the socket adds no trust (DEC-077).

### SPEC-001 § Mechanism — Perimeter (diagram and first prose line)

Before:

```
any local process ──> 127.0.0.1:4000 (relay) ──group──> api.sock (0750 dir) ──> LiteLLM
                      key check fails closed: 401
```

One socket, one relay; the key is the only per-client identity (DEC-047).

After:

```
any local process ──> 127.0.0.1:4000 ───────────────────────────┐
the user's processes ──> /run/llm-gateway-client/api.sock ──────┴─> relay ──group──> api.sock (0750 dir) ──> LiteLLM
                         (user 0600, dir root 0755)                 key check fails closed: 401
```

One gateway socket, one relay with two listeners (DEC-075); the key is the
only per-client identity (DEC-047, DEC-077). The client socket is the relay's,
so the 0750 gate on the gateway socket is unchanged.

NF-003 (REQ-011) holds as written (nothing off loopback; the client socket is
the relay's): no requirement row.

## Reconcile narrative

- [RV-033 F-5]: SPEC-001 did not know the client socket. Reach and Perimeter
  amended as above, citing DEC-075/076/077.
