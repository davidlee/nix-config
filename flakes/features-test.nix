# Resolver tests for ./features.nix. `lib.runTests` returns [] when every test
# passes; perSystem.nix runs this as checks.<system>.features (`just test`).
#
# Fixture trees are written inline. Tests on the real tree (./features) assert
# membership, never equality, so adding a feature does not turn them red.
lib: let
  resolve = import ./features.nix lib;
  real = import ./features;

  area = name: features: {
    inherit name;
    value = features;
  };
  feat = name: value: {inherit name value;};
  on = path: lib.setAttrByPath (["feature"] ++ lib.splitString "." path ++ ["enable"]) true;

  # The resolver fails by `throw`, which tryEval catches. tryEval loses the
  # message, so each failing fixture is paired with a passing twin that
  # differs only in the property under test: [ fixture twin ] -> [ false true ].
  fails = e: !(builtins.tryEval e).success;
  resolves = args:
    !fails
    (resolve ({
        classes = both;
        modules = [];
      }
      // args)).flags;
  one = descriptor: [(area "a" [(feat "x" descriptor)])];
  tags = map (m: m._file);

  hm = {homeManager = {};};
  nixos = {nixos = {};};
  both = ["nixos" "homeManager"];

  workstation = ./features/profiles/workstation.nix;

  # Real tree, both linux classes: is snooze in [ nixos homeManager ]?
  snoozeIn = modules: let
    r = resolve {
      tree = real;
      classes = both;
      inherit modules;
    };
  in [
    (lib.elem "features/session/snooze#nixos" (tags r.modules.nixos))
    (lib.elem "features/session/snooze#homeManager" (tags r.modules.homeManager))
  ];

  prerequisite = selected:
    resolve {
      tree = [(area "a" [(feat "x" (hm // {requires = ["a.y"];})) (feat "y" hm)])];
      classes = both;
      modules = map on selected;
    };
in
  lib.runTests {
    testPrerequisiteOffFails = {
      expr = let r = prerequisite ["a.x"]; in [(fails r.modules.homeManager) (fails r.flags)];
      expected = [true true];
    };

    testPrerequisiteOnPasses = {
      expr = tags (prerequisite ["a.x" "a.y"]).modules.homeManager;
      expected = ["features/a/x#homeManager" "features/a/y#homeManager"];
    };

    testUnknownPrerequisiteFails = {
      expr = map (p: resolves {tree = [(area "a" [(feat "x" (hm // {requires = [p];})) (feat "y" hm)])];}) ["no.such" "a.y"];
      expected = [false true];
    };

    # Checked on every record, selected or not.
    testUnknownDescriptorKeyFails = {
      expr = let
        full = {
          nixos = {};
          homeManager = {};
          darwin = {};
          requires = [];
        };
      in
        map (d: resolves {tree = one d;}) [(full // {homeManger = {};}) full];
      expected = [false true];
    };

    # The selected, self-requiring fixture also proves the dot check runs
    # before the `requires` lookup, which would otherwise abort uncatchably.
    testDottedNameFails = {
      expr = let
        dottedArea = a:
          resolves {
            tree = [(area a [(feat "x" (hm // {requires = ["${a}.x"];}))])];
            modules = [(lib.setAttrByPath ["feature" a "x" "enable"] true)];
          };
        dottedFeature = f: resolves {tree = [(area "a" [(feat f hm)])];};
      in [(dottedArea "a.b") (dottedArea "ab") (dottedFeature "x.y") (dottedFeature "xy")];
      expected = [false true false true];
    };

    # A legacy flag at a feature's path; the twin's flag sits beside it.
    testFlagCollisionFails = {
      expr = map (flag:
        resolves {
          tree = [(area "a" [(feat "x" hm)])];
          modules = [{options = lib.setAttrByPath flag (lib.mkEnableOption "flag");}];
        }) [["a" "x"] ["a" "y"]];
      expected = [false true];
    };

    testFalseAssertionFails = {
      expr = map (assertion:
        resolves {
          tree = one hm;
          modules = [
            {
              assertions = [
                {
                  inherit assertion;
                  message = "m";
                }
              ];
            }
          ];
        }) [false true];
      expected = [false true];
    };

    # Neither unselected value may be forced (throw) or applied (missing pkgs).
    testUnselectedNotForced = {
      expr = let
        r = resolve {
          tree = [
            (area "a" [
              (feat "broken" {nixos = throw "forced an unselected feature";})
              (feat "missing" {nixos = {pkgs, ...}: {environment.systemPackages = [pkgs.does-not-exist];};})
              (feat "ok" {nixos = {marker = true;};})
            ])
          ];
          classes = ["nixos"];
          modules = [(on "a.ok")];
        };
        inherit
          (lib.evalModules {
            modules = r.modules.nixos ++ [{options.marker = lib.mkOption {type = lib.types.bool;};}];
          })
          config
          ;
      in
        removeAttrs config ["_module"];
      expected = {marker = true;};
    };

    testNowhereToLandFails = {
      expr = map (classes:
        resolves {
          tree = one hm;
          inherit classes;
          modules = [(on "a.x")];
        }) [["darwin"] ["darwin" "homeManager"]];
      expected = [false true];
    };

    testListOrder = {
      expr =
        tags
        (resolve {
          tree = [
            (area "zeta" [(feat "z2" nixos) (feat "z1" nixos)])
            (area "alpha" [(feat "a1" nixos)])
          ];
          classes = ["nixos"];
          modules = map on ["alpha.a1" "zeta.z1" "zeta.z2"];
        }).modules.nixos;
      expected = ["features/zeta/z2#nixos" "features/zeta/z1#nixos" "features/alpha/a1#nixos"];
    };

    testDuplicateNamesFail = {
      expr = map (tree: resolves {inherit tree;}) [
        [(area "a" [(feat "x" hm)]) (area "a" [(feat "y" hm)])]
        [(area "a" [(feat "x" hm)]) (area "b" [(feat "y" hm)])]
        [(area "a" [(feat "x" hm) (feat "x" nixos)])]
        [(area "a" [(feat "x" hm) (feat "y" nixos)])]
      ];
      expected = [false true false true];
    };

    testProfileSelectsSnooze = {
      expr = snoozeIn [workstation];
      expected = [true true];
    };

    testHostOverrideWins = {
      expr = snoozeIn [workstation {feature.session.snooze.enable = false;}];
      expected = [false false];
    };

    testFlagsHideSelection = {
      expr = let
        inherit
          (resolve {
            tree = real;
            classes = both;
            modules = [];
          })
          flags
          ;
      in [(flags ? feature) (flags ? assertions) (flags ? games)];
      expected = [false false true];
    };

    testMacSelectsNothing = {
      expr =
        (resolve {
          tree = real;
          classes = ["darwin"];
          modules = [];
        }).modules;
      expected = {
        nixos = [];
        homeManager = [];
        darwin = [];
      };
    };
  }
