# Resolver tests for ./features.nix. `lib.runTests` returns [] when every test
# passes; perSystem.nix runs this as checks.<system>.features (`just test`).
#
# Fixture trees are written inline. Tests on the real tree (./features) assert
# membership, never equality, so adding a feature does not turn them red.
# No test reads a host's or profile's selection: those are choices, and a test
# that pins one breaks the choosing. Select what a test needs with `on`.
lib: let
  resolve = import ./features.nix lib;
  real = import ./features {inherit lib;};

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
  # Defaults: both linux classes on x86_64-linux; `args` override.
  resolves = args:
    !fails
    (resolve ({
        classes = both;
        system = "x86_64-linux";
        modules = [];
      }
      // args)).modules;
  one = descriptor: [(area "a" [(feat "x" descriptor)])];
  # A projected module's `_file` is "<file>:<line> (<area>.<name>#<class>)";
  # tests identify it by the logical part.
  logical = m: lib.head (builtins.match ".*\\((.*)\\)" m._file);
  tags = map logical;
  # The record behind a tag: "<area>.<name>#<class>" -> the feature attrset.
  recordOf = tag: let
    m = builtins.match "([^.]+)\\.([^#]+)#.*" tag;
    treeArea = (lib.findFirst (a: a.name == lib.elemAt m 0) null real).value;
  in
    lib.findFirst (f: f.name == lib.elemAt m 1) null treeArea;

  hm = {homeManager = {};};
  nixos = {nixos = {};};
  both = ["nixos" "homeManager"];

  # A profile in miniature: one mkDefault selection.
  profile = {feature.session.snooze.enable = lib.mkDefault true;};
  personal = ./features/profiles/personal.nix;
  personalLinux = ./features/profiles/personal-linux.nix;

  # Real tree, both linux classes: is snooze in [ nixos homeManager ]?
  snoozeIn = modules: let
    r = resolve {
      system = "x86_64-linux";
      tree = real;
      classes = both;
      inherit modules;
    };
  in [
    (lib.elem "session.snooze#nixos" (tags r.modules.nixos))
    (lib.elem "session.snooze#homeManager" (tags r.modules.homeManager))
  ];

  prerequisite = selected:
    resolve {
      system = "x86_64-linux";
      tree = [(area "a" [(feat "x" (hm // {requires = ["a.y"];})) (feat "y" hm)])];
      classes = both;
      modules = map on selected;
    };
in
  lib.runTests {
    testPrerequisiteOffFails = {
      expr = let r = prerequisite ["a.x"]; in fails r.modules.homeManager;
      expected = true;
    };

    testPrerequisiteOnPasses = {
      expr = tags (prerequisite ["a.x" "a.y"]).modules.homeManager;
      expected = ["a.x#homeManager" "a.y#homeManager"];
    };

    testUnknownPrerequisiteFails = {
      expr = map (p: resolves {tree = [(area "a" [(feat "x" (hm // {requires = [p];})) (feat "y" hm)])];}) ["no.such" "a.y"];
      expected = [false true];
    };

    # `platforms` absent means every system (DEC-030). Cannot be red against a
    # resolver that ignores platforms: it guards against an over-eager check.
    testPlatformsAbsentMeansAll = {
      expr = map (system:
        resolves {
          tree = one hm;
          modules = [(on "a.x")];
          inherit system;
        }) ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];
      expected = [true true true true];
    };

    testUnsupportedPlatformFails = {
      expr = map (system:
        resolves {
          tree = one (hm // {platforms = ["x86_64-linux"];});
          modules = [(on "a.x")];
          inherit system;
        }) ["aarch64-darwin" "x86_64-linux"];
      expected = [false true];
    };

    # Selected on purpose: the shape check must fire before the selection check
    # takes `lib.elem` over a string (a type error tryEval cannot catch).
    testBadPlatformsShapeFails = {
      expr = map (p:
        resolves {
          tree = one (hm // {platforms = p;});
          modules = [(on "a.x")];
        }) ["x86_64-linux" [1] ["x86_64-linux"]];
      expected = [false false true];
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

    # An outer option at a feature's path (DEC-025); the twin's sits beside it.
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
          system = "x86_64-linux";
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
          system = "aarch64-darwin";
          modules = [(on "a.x")];
        }) [["darwin"] ["darwin" "homeManager"]];
      expected = [false true];
    };

    testListOrder = {
      expr =
        tags
        (resolve {
          system = "x86_64-linux";
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
          system = "x86_64-linux";
          tree = real;
          classes = both;
          modules = map on ["session.snooze" "virt.capsule"];
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

    # A profile's mkDefault selects; a host's plain definition overrides it.
    testProfileSelects = {
      expr = snoozeIn [profile];
      expected = [true true];
    };

    testHostOverrideWins = {
      expr = snoozeIn [profile {feature.session.snooze.enable = false;}];
      expected = [false false];
    };

    # The selection reaches no evaluation except as modules.
    testResultIsModulesOnly = {
      expr = builtins.attrNames (resolve {
        system = "x86_64-linux";
        tree = real;
        classes = both;
        modules = [];
      });
      expected = ["modules"];
    };

    # personal is portable: it resolves on a Mac and selects no record that
    # carries platforms. Guarded (`ok &&`): an unguarded resolve that throws
    # would end the run instead of reading false.
    testPersonalSelectsPortable = let
      args = {
        modules = [personal];
        system = "aarch64-darwin";
        tree = real;
        classes = ["darwin" "homeManager"];
      };
      ok = resolves args;
      r = (resolve args).modules;
      hmTags = tags r.homeManager;
      allTags = hmTags ++ tags r.darwin ++ tags r.nixos;
    in {
      expr = [
        ok
        (ok && hmTags != []) # not vacuous
        (ok && !lib.any (t: (recordOf t) ? platforms) allTags)
      ];
      expected = [true true true];
    };

    # satan.attrd needs its postgres; satan.harness needs emacsclient;
    # audio.alarm calls spotify_player. No host file, whose plain selections
    # would satisfy the requires.
    testPersonalRequires = {
      expr = map (sel:
        resolves {
          tree = real;
          modules = map on sel;
        }) [
        ["satan.attrd"]
        ["satan.attrd" "services.postgresql"]
        ["satan.harness"]
        ["satan.harness" "editor.emacs"]
        ["audio.alarm"]
        ["audio.alarm" "media.spotify"]
      ];
      expected = [false true false true false true];
    };

    # Both linux classes on both systems, so only `platforms` can refuse (as
    # testDesktopCoreLinuxOnly).
    testPersonalLinuxOnDarwinFails = {
      expr = map (system:
        resolves {
          tree = real;
          modules = [personalLinux];
          inherit system;
        }) ["aarch64-darwin" "x86_64-linux"];
      expected = [false true];
    };

    # gamescopeSession is a steam option: gamescope alone is refused. No host
    # file, whose plain selections would fail a twin for the wrong reason.
    testGamescopeRequiresSteam = {
      expr = map (sel:
        resolves {
          tree = real;
          modules = map on sel;
        }) [["games.gamescope"] ["games.gamescope" "games.steam"]];
      expected = [false true];
    };

    # Compositors run on the shared stack; no host file.
    testCompositorRequiresCore = {
      expr = map (sel:
        resolves {
          tree = real;
          modules = map on sel;
        }) [["compositor.sway"] ["compositor.sway" "desktop.core"]];
      expected = [false true];
    };

    # wlrobs needs core's v4l2loopback; `requires` checks selection only.
    testObsRequiresCore = {
      expr = map (sel:
        resolves {
          tree = real;
          modules = map on sel;
        }) [["media.obs"] ["media.obs" "desktop.core"]];
      expected = [false true];
    };

    # eca's jail takes its key and relay from the gateway; `requires` checks
    # selection only.
    testEcaRequiresGateway = {
      expr = map (sel:
        resolves {
          tree = real;
          modules = map on sel;
        }) [["agents.eca"] ["agents.eca" "agents.gateway"]];
      expected = [false true];
    };

    # Both linux classes on both systems, so only `platforms` can refuse:
    # with a darwin host's own classes, D6 (nowhere to land) would refuse the
    # pre-P3 nixos-only record too, and the test would pass vacuously.
    testDesktopCoreLinuxOnly = {
      expr = map (system:
        resolves {
          tree = real;
          modules = [(on "desktop.core")];
          inherit system;
        }) ["aarch64-darwin" "x86_64-linux"];
      expected = [false true];
    };
  }
