# Tests for ./probes.nix's `resolve`. `lib.runTests` returns [] when every
# test passes; probes.nix runs this as checks.<system>.workarounds
# (`just test`).
#
# resolve: [probe] -> [probe // {storePath}]. Structure is validated when the
# list is forced; storePath is a thunk, forced only by whoever reads it.
# pkgs is the plain perSystem nixpkgs, the reference for `hello`.
{
  lib,
  resolve,
  pkgs,
}: let
  inherit (pkgs.stdenv.hostPlatform) system;
  pinFilter = import ./pin-filter.nix;

  # Validation fails by `throw`, which tryEval catches but whose message it
  # loses, so each failing fixture is paired with a passing twin that differs
  # only in the property under test: [ fixture twin ] -> [ false true ].
  passes = x: (builtins.tryEval (builtins.deepSeq x true)).success;

  # Structural validation is eager: forcing the list itself, not any record
  # in it, fails, so a bad probe fails whatever pin is filtered for.
  validates = probe: (builtins.tryEval (builtins.length (resolve [probe]))).success;
  pairValid = fixture: twin: [(validates fixture) (validates twin)];

  # The resolved storePath of one probe.
  storePathOf = probe: (builtins.head (resolve [probe])).storePath;
  resolves = probe: passes (storePathOf probe);
  pairResolves = fixture: twin: [(resolves fixture) (resolves twin)];

  ok = {
    attr = ["hello"];
    pin = "nixpkgs";
    inherit system;
    issue = "ISS-007";
    reason = "fixture";
    sites = ["fixture.nix"];
  };
  missing = ok // {attr = ["no-such-package-sl012"];};
  unfree = ok // {attr = ["yed"];};
  manual = {signal = "manual";};
in
  lib.runTests {
    testProbeResolves = {
      expr = storePathOf ok;
      expected = pkgs.hello.outPath;
    };

    testProbeKeepsItsKeys = {
      expr = removeAttrs (builtins.head (resolve [ok])) ["storePath"];
      expected = ok // {signal = null;};
    };

    testUnknownKeyFails = {
      expr = pairValid (ok // {sitess = ["x"];}) (ok // {signal = "manual";});
      expected = [false true];
    };

    testMissingKeyFails = {
      expr = pairValid (removeAttrs ok ["sites"]) ok;
      expected = [false true];
    };

    testAttrTypeFails = {
      expr = pairValid (ok // {attr = "hello";}) ok;
      expected = [false true];
    };

    testEmptyAttrFails = {
      expr = pairValid (ok // {attr = [];}) ok;
      expected = [false true];
    };

    testSitesTypeFails = {
      expr = pairValid (ok // {sites = "x";}) ok;
      expected = [false true];
    };

    testUnknownPinFails = {
      expr = pairValid (ok // {pin = "stable";}) (ok // {pin = "nixpkgs-home";});
      expected = [false true];
    };

    testIssueShapeFails = {
      expr = [(validates (ok // {issue = "ISS-7";})) (validates (ok // {issue = "FOO-007";})) (validates (ok // {issue = "CHR-016";}))];
      expected = [false false true];
    };

    testUnknownSystemFails = {
      expr = pairValid (ok // {system = "x86_64-freebsd";}) ok;
      expected = [false true];
    };

    testUnknownSignalFails = {
      expr = pairValid (ok // {signal = "skip";}) (ok // manual);
      expected = [false true];
    };

    # An attr missing from the pin fails only when storePath is forced.
    testMissingAttrIsLazy = {
      expr = [(validates missing) (resolves missing) (resolves ok)];
      expected = [true false true];
    };

    # Unfree is never cached, so it must be manual (RV-025 F-2).
    testUnfreeNeedsManual = {
      expr = pairResolves unfree (unfree // manual);
      expected = [false true];
    };

    testManualHasNoStorePath = {
      expr = storePathOf (unfree // manual);
      expected = null;
    };

    # A manual probe whose package left the pin still fails.
    testManualMissingAttrFails = {
      expr = pairResolves (missing // manual) (ok // manual);
      expected = [false true];
    };

    # RV-025 F-3: the check's filter selects by pin before any storePath is
    # forced, so a broken probe on one pin cannot abort the other's check.
    testPinFilterLeavesOtherPinUnforced = let
      probes = resolve [(missing // {pin = "nixpkgs-home";}) ok];
    in {
      expr = [(passes (pinFilter "nixpkgs" probes)) (passes (pinFilter "nixpkgs-home" probes)) (passes (pinFilter null probes))];
      expected = [true false false];
    };
  }
