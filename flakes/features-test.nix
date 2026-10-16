# Resolver tests for ./features.nix. `lib.runTests` returns [] when every test
# passes; perSystem.nix runs this as checks.<system>.features (`just test`).
#
# Fixture trees are written inline. Tests on the real tree (./features) assert
# membership, never equality, so adding a feature does not turn them red.
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

  hm = {homeManager = {};};
  nixos = {nixos = {};};
  both = ["nixos" "homeManager"];

  workstation = ./features/profiles/workstation.nix;

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

  # Sleipnir's selection plus extra outer modules, real tree. Per
  # "<area>.<name>#nixos" tag: [ projected into nixos, any half of that
  # feature projected into home ].
  sleipnirWith = extra: let
    r = resolve {
      system = "x86_64-linux";
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

    testMacSelectsNothing = {
      expr =
        (resolve {
          system = "aarch64-darwin";
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

    # Features migrated from legacy flags (SL-005, SL-006), each with its
    # [nixos, home] halves.
    testSleipnirSelectsMigrated = let
      nixosOnly = [
        "virt.qemu#nixos"
        "virt.docker#nixos"
        "non-nix-packages.appimage#nixos"
        "non-nix-packages.flatpak#nixos"
        "games.steam#nixos"
        "games.gamescope#nixos"
        "audio.mpd#nixos"
        "services.printing#nixos"
        "services.webserver#nixos"
        "compositor.cosmic#nixos"
        "compositor.kde#nixos"
        "compositor.mango#nixos"
        "desktop.fonts#nixos" # through the workstation profile
        "desktop.greeter#nixos"
        "compositor.umbriel#nixos"
        "shell.noctalia#nixos"
        "audio.pipewire#nixos" # through the workstation profile
        "hardware.bluetooth#nixos"
        "hardware.qmk#nixos"
        "hardware.tablet#nixos"
        "hardware.logitech#nixos"
        "services.postgresql#nixos"
      ];
      bothHalves = [
        "compositor.sway#nixos"
        "compositor.niri#nixos"
        "desktop.core#nixos" # through the workstation profile
      ];
      homeOnly = [
        "games.mangohud#homeManager"
        "audio.dictate#homeManager" # through the workstation profile
        "compositor.sway#homeManager"
        "compositor.niri#homeManager"
      ];
    in {
      expr = sleipnirSelects (nixosOnly ++ bothHalves ++ homeOnly);
      expected =
        map (_: [true false]) nixosOnly
        ++ map (_: [true true]) bothHalves
        ++ map (_: [false true]) homeOnly;
    };

    # P3 home features Sleipnir selects, directly or through workstation.
    # Grows in P4 and P5.
    testSleipnirHomeSelection = let
      r = resolve {
        system = "x86_64-linux";
        tree = real;
        classes = both;
        modules = [./hosts/Sleipnir/features.nix];
      };
      want = [
        "desktop.core#homeManager"
        "web.browsers#homeManager" # workstation
        "terminal.emulators#homeManager" # workstation
        "comms.chat#homeManager" # workstation
        "comms.mail#homeManager" # workstation
        "media.players#homeManager" # workstation
        "media.spotify#homeManager"
        "media.obs#homeManager"
        "graphics.paint#homeManager"
        "graphics.modelling#homeManager"
        "graphics.cad#homeManager"
        "editor.zed#homeManager"
        "editor.lem#homeManager"
        "notes.joplin#homeManager"
        "ai.claude-desktop#homeManager"
        "shell.walker#homeManager"
      ];
    in {
      expr = map (tag: lib.elem tag (tags r.modules.homeManager)) want;
      expected = map (_: true) want;
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

    # Off features (ADR-005): Sleipnir leaves each unselected, and selecting it
    # projects its NixOS half — the second element keeps the first from passing
    # vacuously.
    testOffFeatures = {
      expr = map (tag:
        sleipnirSelects [tag] ++ sleipnirWith [(on (lib.removeSuffix "#nixos" tag))] [tag]) [
        "ai.llama-cpp#nixos"
        "ai.rocm#nixos"
        "virt.podman#nixos" # DEC-022: exclusive with docker, so no host selects it
        "audio.speech#nixos"
        "services.sunshine#nixos"
      ];
      expected = lib.replicate 5 [[false false] [true false]];
    };
  }
