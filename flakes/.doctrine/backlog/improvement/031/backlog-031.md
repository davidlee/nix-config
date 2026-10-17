# IMP-031: Shared evalModules schema helper for host-meta.nix and workarounds/probes.nix

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

`hosts/*/meta.nix` validation (host-meta.nix) and `workarounds/probes.nix` both
validate plain-data records with `lib.evalModules`. Factor a helper
(`lib: options: file: value:`) and fold in probes.nix's own missing-key check,
since the module system's "accessed but has no value defined" names neither the
file nor the record without `--show-trace`. host-meta.nix has that blind spot.
SL-012 PHASE-02 notes; RV-027 F-6.
