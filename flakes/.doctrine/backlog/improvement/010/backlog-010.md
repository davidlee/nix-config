# IMP-010: Validate hosts/<h>/meta.nix

MULTIHOST follow-up, before S8. A misspelled `kind` silently drops the host. Validate with a small `lib.evalModules` schema (kind enum), like features.nix; leaves room for lima/microvm kinds.
