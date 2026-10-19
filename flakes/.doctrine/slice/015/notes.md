# Notes SL-015: Gateway and launch-dir options for network-isolated jails

Durable per-slice scratchpad — tracked in git. The place to lift anything from a
disposable phase sheet (`.doctrine/state/.../phase-NN.md`) that must survive
`rm -rf` before the slice close-out audit harvests it.

## Design triage (2026-10-20, exploring)

Evidence: `research/research.md` (✓ rows only are load-bearing).

**Constraining governance.** ADR-004 D4 (client socket path is a shared
constant in `agents/gateway.nix`); DEC-047 (one socket, keys authenticate,
`0750` gate kept); DEC-049 (key custody unchanged); DEC-059 (`gatewayClient`);
SPEC-001 § Client contract + § Perimeter (change only by decision; REV at
reconcile); POL-001 (nothing secret added).

**Shaping decisions to make** (one inquiry each):
1. Relay topology: one socket unit, two listeners (P2 verified).
2. Transport vs key custody (OQ-1): `jailed-malebolge` uses no `gateway`.
3. The DEC-047 extension and its egress sentence ("network" egress only).
4. Launch-dir option shape; `--chdir` always passed.
5. `offline` + gateway (OQ-2): refuse TCP, default socket, or backlog.
6. openssh for room clients: jailLib or satan `extraPkgs`.
7. Verification: no VM test exists; launcher tests + a live probe.

**Risks.** Bound unix sockets are channels to host processes (satan's to
audit). Room ssh config names a store-path socat that must be in the jail
closure (satan-side; report to SL-027).

**Assumptions.** A-1, A-2 verified (`research/raw/probes.md`).

## Design review passes (2026-10-20, reviewing)

- Pass 1, informal, pre-draft: GPT (gpt-6-sol via Codex) on the decisions.
  Seven findings; adjudicated in the run: F-1, F-2, F-4, F-5, F-7 accepted
  (DEC-076, DEC-077 amended), F-6 partly (no userns in the build sandbox:
  behaviour test without bwrap + VA), F-3 rejected (forwarder death is
  visible). No RV ledger.
- A further pass would probe: the forwarder script itself (bash `read` over
  `/proc/net/tcp`, port hex, `exec` with jail.nix's wrap-entry `"$@"`
  quoting), the `defer` guard's interaction with `include-once "network"`,
  and the `profiles` refactor keeping specDev/research argv byte-identical.
  All three are code-level and covered by sec-7 VT 1-5; a design-level pass
  adds little. Recommendation: waive, and review the code at audit.

## Harvest
<!-- single-copy: updated in place each harvest; ids only, never restated content -->
fresh-as-of: <yyyy-mm-dd> · <PHASE-NN | stage> · <head-commit>

### Produced

### Learned

### Open
