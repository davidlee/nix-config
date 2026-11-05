`doctrine slice phase … completed` records the phase boundary's `code_end_oid` from HEAD. If the phase's commit lands after the flip, start equals end and the delta is empty.

`doctrine slice conformance` does not report this as `incomplete`: the row exists, so the phase's paths silently vanish from every cell. Seen on SL-024: PHASE-01 and PHASE-02 had empty rows, and conformance listed no `agents/*.nix` at all (RV-049 F-3).

Check: in this repo the registry is `~/.cfg/.doctrine/state/slice/<id>/boundaries.toml`; look for `code_start_oid == code_end_oid`.

Fix: commit before completing the phase, or afterwards run `doctrine slice record-delta <id> PHASE-NN --commit <sha>`.