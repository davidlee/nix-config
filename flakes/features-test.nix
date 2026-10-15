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
  feat = name: descriptor: descriptor // {inherit name;};
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
  # A projected module's `_file` is "<file>:<line> (<area>.<name>#<class>)";
  # tests identify it by the logical part.
  logical = m: lib.head (builtins.match ".*\\((.*)\\)" m._file);
  tags = map logical;

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
    (lib.elem "session.snooze#nixos" (tags r.modules.nixos))
    (lib.elem "session.snooze#homeManager" (tags r.modules.homeManager))
  ];

  # Sleipnir's selection plus extra outer modules, real tree. Per
  # "<area>.<name>#nixos" tag: [ projected into nixos, any half of that
  # feature projected into home ].
  sleipnirWith = extra: let
    r = resolve {
      tree = real;
      classes = both;
      modules = [./hosts/Sleipnir/features.nix] ++ extra;
    };
  in
    map (tag: [
      (lib.elem tag (tags r.modules.nixos))
      (lib.any (lib.hasPrefix (lib.removeSuffix "nixos" tag)) (tags r.modules.homeManager))
    ]);
  sleipnirSelects = sleipnirWith [];

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
      expected = ["a.x#homeManager" "a.y#homeManager"];
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
      expected = ["zeta.z2#nixos" "zeta.z1#nixos" "alpha.a1#nixos"];
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

    # The likeliest spill mistake: listing a feature's file, not importing it.
    testNonRecordFeatureFails = {
      expr = map (f: resolves {tree = [(area "a" [f])];}) [./features/virt/capsule.nix (import ./features/virt/capsule.nix)];
      expected = [false true];
    };

    testUnnamedFeatureFails = {
      expr = map (f: resolves {tree = [(area "a" [f])];}) [nixos (feat 5 nixos) (feat "x" nixos)];
      expected = [false false true];
    };

    testEmptyNameFails = {
      expr = map (tree: resolves {inherit tree;}) [
        [(area "" [(feat "x" hm)])]
        [(area "a" [(feat "" hm)])]
        [(area "a" [(feat "x" hm)])]
      ];
      expected = [false false true];
    };

    # Shapes the later checks cannot read; each must fail as a throw.
    testMalformedShapeFails = {
      expr = map (tree: resolves {inherit tree;}) [
        [{value = [];}]
        [(area 1 [])]
        [(area "a" {x = hm;})]
        [(area "a" [(feat "x" (hm // {requires = "a.x";}))])]
        [(area "a" [(feat "x" (hm // {requires = [1];}))])]
        [(area "a" [(feat "x" (hm // {requires = ["a.x"];}))])]
      ];
      expected = [false false false false false true];
    };

    # Each projected module's _file names, relative to the flake, the line
    # where its feature is named, and which feature it is: inline and spilled.
    testProvenance = {
      expr = let
        r = resolve {
          tree = real;
          classes = both;
          modules = [workstation ./hosts/Sleipnir/features.nix];
        };
        namedAt = m: let
          at = builtins.match "(.*):([0-9]+) \\((.*)\\.(.*)#.*\\)" m._file;
          line = lib.elemAt (lib.splitString "\n" (builtins.readFile (./. + "/${lib.elemAt at 0}"))) (lib.toInt (lib.elemAt at 1) - 1);
        in
          lib.hasInfix "name = \"${lib.elemAt at 3}\";" line;
        find = tag: lib.findFirst (m: logical m == tag) null r.modules.nixos;
      in
        map (tag: namedAt (find tag)) ["session.snooze#nixos" "virt.capsule#nixos"];
      expected = [true true];
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
          classes = ["darwin" "homeManager"];
          modules = [];
        }).modules;
      expected = {
        nixos = [];
        homeManager = [];
        darwin = [];
      };
    };

    # Sleipnir's own selection projects capsule's NixOS half, and no home half.
    testSleipnirSelectsCapsule = {
      expr = sleipnirSelects ["virt.capsule#nixos"];
      expected = [[true false]];
    };

    # Features migrated from legacy flags (SL-005): NixOS half only, each.
    testSleipnirSelectsMigrated = {
      expr = sleipnirSelects ["virt.qemu#nixos" "virt.docker#nixos"];
      expected = [[true false] [true false]];
    };

    # podman is an off feature (DEC-022): Sleipnir leaves it unselected, and
    # selecting it projects its NixOS half.
    testSleipnirLeavesPodmanOff = {
      expr = sleipnirSelects ["virt.podman#nixos"];
      expected = [[false false]];
    };

    testPodmanSelectable = {
      expr = sleipnirWith [(on "virt.podman")] ["virt.podman#nixos"];
      expected = [[true false]];
    };
  }
