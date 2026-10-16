# Schema tests for ./host-meta.nix. `lib.runTests` returns [] when every test
# passes; perSystem.nix runs this as checks.<system>.host-meta (`just test`).
lib: let
  validate = import ./host-meta.nix lib "fixture/meta.nix";

  # Validation fails by `throw`, which tryEval catches but whose message it
  # loses, so each failing fixture is paired with a passing twin that differs
  # only in the property under test: [ fixture twin ] -> [ false true ].
  passes = meta: (builtins.tryEval (builtins.deepSeq (validate meta) true)).success;
  pair = fixture: twin: [(passes fixture) (passes twin)];

  ok = {
    kind = "nixos";
    system = "x86_64-linux";
  };
in
  lib.runTests {
    testMetaPasses = {
      expr = validate ok;
      expected = ok // {home = false;};
    };

    testMetaUnknownKindFails = {
      expr = pair (ok // {kind = "nixso";}) (ok // {kind = "darwin";});
      expected = [false true];
    };

    testMetaUnknownKeyFails = {
      expr = pair (ok // {homee = true;}) (ok // {home = true;});
      expected = [false true];
    };

    testMetaMissingSystemFails = {
      expr = pair (removeAttrs ok ["system"]) ok;
      expected = [false true];
    };

    testMetaHomeTypeFails = {
      expr = pair (ok // {home = "yes";}) (ok // {home = true;});
      expected = [false true];
    };
  }
