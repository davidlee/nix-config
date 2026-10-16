# Resolves one host's feature selection, once, outside the NixOS, darwin and
# home-manager module systems. Those three evaluate independently (separate
# nixpkgs, separate `switch`), so an option declared in one is invisible to
# the others; hosts.nix resolves here and hands each evaluation its share.
#
#   lib -> { tree, classes, system, modules } -> { modules }   (or throws)
#
# The feature tree (./features) gives one `feature.<area>.<name>.enable`
# option per feature, set by the host and the profiles it imports. Selected
# features are projected into `modules.<class>` in tree order, for the
# factories to append. No downstream module sees the selection.
#
# tree     [ { name = area; value = [ feature … ]; } … ], i.e. `import ./features {inherit lib;}`
# classes  this host's evaluations, e.g. [ "nixos" "homeManager" ]
# system   this host's system, e.g. "x86_64-linux"
# modules  outer modules: the host's features.nix (if any), plus extras
#
# A feature is { name, nixos?, homeManager?, darwin?, requires?, platforms? }.
# `platforms` lists the systems it supports; absent means every system
# (DEC-030). The resolver reads only key names, `name`, `requires`,
# `platforms` and the position of `name`; class values are never forced here, so an unselected feature's
# implementation is never evaluated. Every check is enforced: a failure
# throws, so nothing in the result can be read.
lib: {
  tree,
  classes,
  system,
  modules,
}: let
  inherit (lib) concatMap concatStringsSep filter mkEnableOption mkOption types;

  records = concatMap (area:
    map (f: {
      area = area.name;
      inherit (f) name;
      path = "${area.name}.${f.name}";
      descriptor = f;
    })
    area.value)
  tree;

  options = {
    options.feature = lib.listToAttrs (map (area: {
        inherit (area) name;
        value = lib.listToAttrs (map (f: {
            inherit (f) name;
            value.enable = mkEnableOption "feature ${area.name}.${f.name}";
          })
          area.value);
      })
      tree);
    options.assertions = mkOption {
      type = types.listOf (types.submodule {
        options.assertion = mkOption {type = types.bool;};
        options.message = mkOption {type = types.str;};
      });
      default = [];
      description = "Checks on the selection; any false one fails resolution.";
    };
  };

  # Per selected feature: its prerequisites are selected, it has a module
  # for at least one of this host's classes (ADR-005 D6), and its platforms
  # include this host's system (DEC-030).
  checks = {config, ...}: let
    enabled = path: lib.getAttrFromPath (lib.splitString "." path ++ ["enable"]) config.feature;
  in {
    assertions = concatMap (r:
      lib.optionals (enabled r.path) (
        map (p: {
          assertion = enabled p;
          message = "feature.${r.path} requires feature.${p}, which is not selected";
        }) (r.descriptor.requires or [])
        ++ [
          {
            assertion = lib.any (c: r.descriptor ? ${c}) classes;
            message = "feature.${r.path} is selected but has no module for this host's evaluations (${concatStringsSep ", " classes})";
          }
          {
            assertion = lib.elem system (r.descriptor.platforms or [system]);
            message = "feature.${r.path} is selected but does not support ${system} (platforms: ${concatStringsSep ", " (r.descriptor.platforms or [])})";
          }
        ]
      ))
    records;
  };

  outer = lib.evalModules {modules = [options checks] ++ modules;};
  inherit (outer) config;

  # Structural errors, over every record, selected or not. They read only
  # names, descriptor key names, `requires`, `platforms` and option declarations, never a
  # class value or a config value (ADR-002 D4), so all are safe to compute
  # together; `checks` looks paths up by splitting on ".", so it must not run
  # until these pass. Everything after `badShapes` reads area and feature
  # names, area lists, `requires` and `platforms` lists, and a missing attribute or a type
  # error aborts uncatchably, so a shape those reads cannot take is reported
  # alone.
  strings = xs: lib.isList xs && lib.all lib.isString xs;
  badShapes = lib.concatLists (lib.imap1 (j: area:
    if !(lib.isAttrs area && lib.isString (area.name or null) && lib.isList (area.value or null))
    then ["area #${toString j} is not { name = <string>; value = [ feature … ]; }"]
    else
      lib.concatLists (lib.imap1 (i: f:
        if builtins.isPath f
        then ["feature #${toString i} in area ${area.name} is a path; list a feature's own file as (import ./${area.name}/<name>.nix)"]
        else if !lib.isAttrs f
        then ["feature #${toString i} in area ${area.name} is not a record"]
        else if !lib.isString (f.name or null)
        then ["feature #${toString i} in area ${area.name} has no string name"]
        else
          lib.optional (!strings (f.requires or [])) "feature ${area.name}.${f.name}: requires is not a list of strings"
          ++ lib.optional (!strings (f.platforms or [])) "feature ${area.name}.${f.name}: platforms is not a list of strings")
      area.value))
  tree);
  areas = map (a: a.name) tree;
  paths = map (r: r.path) records;
  duplicates = xs: lib.unique (filter (x: lib.count (y: y == x) xs > 1) xs);
  # A name is one segment of a dotted path: not empty, no dot.
  badName = n: n == "" || lib.hasInfix "." n;
  structural =
    if badShapes != []
    then badShapes
    else
      map (a: "duplicate area ${a}") (duplicates areas)
      ++ map (p: "duplicate feature ${p}") (duplicates paths)
      ++ map (a: "area name \"${a}\" is empty or contains \".\"") (filter badName areas)
      ++ map (r: "feature name \"${r.name}\" in area ${r.area} is empty or contains \".\"") (filter (r: badName r.name) records)
      ++ concatMap (r: let
        bad = lib.subtractLists ["name" "nixos" "homeManager" "darwin" "requires" "platforms"] (builtins.attrNames r.descriptor);
      in
        lib.optional (bad != []) "unknown descriptor key(s) ${concatStringsSep ", " bad} in feature ${r.path}")
      records
      # An outer option at a feature's path would be a second switch for that feature (DEC-025).
      ++ map (r: "feature ${r.path} is also an outer option") (filter (r: lib.isOption (lib.attrByPath [r.area r.name] null outer.options)) records)
      ++ concatMap (r:
        map (p: "unknown feature ${p} in ${r.path}.requires")
        (filter (p: !lib.elem p paths) (r.descriptor.requires or [])))
      records;
  failed = filter (a: !a.assertion) config.assertions;
  selected = filter (r: config.feature.${r.area}.${r.name}.enable) records;

  bullets = lib.concatMapStrings (m: "- ${m}\n");

  # Where a feature is written, as "<file>:<line>" relative to the flake, from
  # the position of its `name`. Relative, for readable errors; this holds for
  # records written in this flake. A record from elsewhere (a flake input)
  # keeps its absolute path, as removePrefix leaves a non-match unchanged.
  root = "${toString ./.}/";
  origin = f: let
    pos = builtins.unsafeGetAttrPos "name" f;
  in
    if pos == null
    then "unknown"
    else "${lib.removePrefix root pos.file}:${toString pos.line}";

  # _file names the feature in error messages, by place and by path; imports
  # never forces the value.
  project = class:
    map (r: {
      _file = "${origin r.descriptor} (${r.path}#${class})";
      imports = [r.descriptor.${class}];
    })
    (filter (r: r.descriptor ? ${class}) selected);
in
  if structural != []
  then throw "feature tree is malformed:\n${bullets structural}"
  else if failed != []
  then throw "feature selection failed:\n${bullets (map (a: a.message) failed)}"
  else {
    modules = lib.genAttrs ["nixos" "homeManager" "darwin"] project;
  }
