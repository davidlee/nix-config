`quotient.lib.checkFormFamily` reads a form's launcher text and fails
"the bwrap line is not plain words" on anything it cannot resolve statically:
a process substitution (`--args 23 23< <(…)`), `$(…)`, or a parameter
expansion beyond a name or plain default (`${NAME+…}`).

Bitten twice:
- fd-bind args (`hostDoctrineOptions`, host git excludes) — IMP-052 moved them
  to `add-runtime` code appending to `RUNTIME_ARGS`.
- jail.nix `try-fwd-env` renders `${NAME+--setenv NAME "$NAME"}` — use
  `jailLib.tryFwdEnv c "NAME"` instead (CHR-023, agents 53ffeefa).

Rule: any option shared by a jail and a quotient form (the lib `posture`, a
project's `projectOptions = c: [ … ]`) must keep the bwrap line plain; put
launch-time logic in `c.add-runtime` and append to `RUNTIME_ARGS`. The check
lists those as residue (runtime binds it cannot see), which is accepted.

Verify a family with a flake check: `checks.quotient-forms =
quotient.lib.checkFormFamily { inherit pkgs; family = …; }` (doctrine's
flake.nix has one).
