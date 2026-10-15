`builtins.tryEval` catches `throw` and failed `assert`s. It does not catch
`abort` (e.g. `lib.getAttrFromPath` on a missing path), a missing attribute,
or a type/coercion error: those end the whole evaluation. It also discards
the message.

Consequences for `lib.runTests` suites (e.g. `features-test.nix`):
- code under test must fail by `throw`, and must validate inputs before any
  lookup that could abort (the resolver's structural checks, RV-002 F-2);
- a bare "it fails" test passes on *any* throw: pair each failing fixture
  with a passing twin that differs only in the property under test
  (`[fixture twin] -> [false true]`, RV-002 F-4);
- message text can't be asserted in pure eval; check wording by eye.
