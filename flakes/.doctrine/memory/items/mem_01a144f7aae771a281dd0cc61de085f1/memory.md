`builtins.addErrorContext msg e` adds `msg` only to errors raised **while
evaluating `e` to weak-head normal form**. `(lib.evalModules …).config` is an
attrset whose option values are thunks, so an error inside one (e.g. "The
option `system' was accessed but has no value defined") fires later, when a
consumer forces the field, outside the context, and the trace omits `msg`.

Force inside the context: `addErrorContext msg (builtins.deepSeq c c)`
(`host-meta.nix`, SL-009 PHASE-02). Errors that carry `_file`, such as an
unknown option or a type mismatch ("In `hosts/X/meta.nix'"), name the file
anyway. Missing-option errors don't.

Check by eye with `nix eval --impure --expr 'import ./x.nix (builtins.getFlake
"nixpkgs").lib …'`: tryEval-based tests can't see the message
([[mem.fact.nix.tryeval-scope]]).
