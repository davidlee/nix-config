# The probe registry (design SL-012 sec-2, DEC-053, DEC-055): validates
# ./default.nix and resolves each probe's store path, for workarounds/check.
#
#   flake.workaroundProbes   [probe // {storePath}], signal defaulted to null
#   checks.<system>.workarounds   ./probes-test.nix, which also tests
#                                 ./last-good.nix against the stable input
#
# Structure is checked when the list is forced, naming the probe: an unknown
# key or a wrong type through the module system's `_file` (the
# ./host-meta.nix idiom), a missing key by a check of its own.
#
# storePath stays a thunk until read, so a filter on `pin` (./pin-filter.nix)
# never resolves the other pin's probes (RV-025 F-3). Forcing it imports the
# pin for the probe's system, with no overlays (what Hydra builds), and fails,
# naming the probe, when the attr is missing or is unfree without
# `signal = "manual"` (never cached, RV-025 F-2). A manual probe's storePath
# is null once its attr is found.
{
  inputs,
  config,
  ...
}: let
  inherit (inputs.nixpkgs) lib;

  pins = ["nixpkgs" "nixpkgs-home"];

  # Lazy: each pin x system is imported at most once, and only when read.
  pkgsFor = lib.genAttrs pins (pin:
    lib.genAttrs config.systems (system:
      import inputs.${pin} {
        inherit system;
        config.allowUnfree = true;
      }));

  options = with lib.types; {
    attr = lib.mkOption {type = nonEmptyListOf str;};
    pin = lib.mkOption {type = enum pins;};
    system = lib.mkOption {type = enum config.systems;};
    issue = lib.mkOption {type = strMatching "(ISS|IMP|CHR|RSK|IDE)-[0-9]{3}";};
    reason = lib.mkOption {type = str;};
    sites = lib.mkOption {type = nonEmptyListOf str;};
    signal = lib.mkOption {
      type = nullOr (enum ["manual"]);
      default = null;
    };
  };
  required = lib.attrNames (lib.filterAttrs (_: o: !(o ? default)) options);

  # n, probe -> {label; probe}: the validated probe, and the name its errors
  # use (n counts from 1).
  validate = n: probe: let
    attr = probe.attr or null;
    name =
      if builtins.isList attr && lib.all builtins.isString attr
      then lib.concatStringsSep "." attr
      else "?";
    label = "workarounds/default.nix, probe ${toString n} (${name})";
    # Checked first: the module system's message for a missing option names
    # neither `_file` nor, in a truncated trace, any error context.
    absent = lib.subtractLists (lib.attrNames probe) required;
    checked =
      removeAttrs
      (lib.evalModules {
        modules = [
          {inherit options;}
          {
            _file = label;
            config = probe;
          }
        ];
      }).config ["_module"];
  in {
    inherit label;
    probe =
      if builtins.isAttrs probe && absent != []
      then throw "${label}: missing ${lib.concatStringsSep ", " absent}"
      else checked;
  };

  # hasAttrByPath first: getAttrFromPath on a missing path aborts, which
  # tryEval cannot catch (mem.fact.nix.tryeval-scope).
  storePathOf = {
    label,
    probe,
  }: let
    pkgs = pkgsFor.${probe.pin}.${probe.system};
    pkg = lib.getAttrFromPath probe.attr pkgs;
  in
    if !lib.hasAttrByPath probe.attr pkgs
    then throw "${label}: not in ${probe.pin} for ${probe.system}"
    else if probe.signal == "manual"
    then null
    else if pkg.meta.unfree or false
    then throw "${label}: unfree, never on cache.nixos.org: set signal = \"manual\" (RV-025 F-2)"
    else pkg.outPath;

  resolve = probes: let
    validated = lib.imap1 validate probes;
  in
    builtins.deepSeq validated (map (v: v.probe // {storePath = storePathOf v;}) validated);
in {
  flake.workaroundProbes = resolve (import ./default.nix);

  perSystem = {pkgs, ...}: {
    # Evaluating the tests is the test; the build is a stub (as checks.host-meta).
    checks.workarounds = let
      failures = import ./probes-test.nix {
        inherit lib resolve pkgs;
        lastGood = import ./last-good.nix;
        # A historical revision already in the lock: no fetch of its own.
        stable = {inherit (inputs.stable) rev narHash;};
        stableHello = (import inputs.stable {inherit (pkgs.stdenv.hostPlatform) system;}).hello.outPath;
      };
    in
      if failures == []
      then pkgs.runCommand "workarounds-test" {} "touch $out"
      else throw "probes-test.nix failed:\n${lib.generators.toPretty {} failures}";
  };
}
