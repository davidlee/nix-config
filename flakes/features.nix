# Resolves one host's feature selection, once, outside the NixOS, darwin and
# home-manager module systems. Those three evaluate independently (separate
# nixpkgs, separate `switch`), so an option declared in one is invisible to
# the others; hosts.nix resolves here and hands each evaluation its share.
#
#   lib -> { tree, classes, modules } -> { flags, modules }   (or throws)
#
# Two paths coexist:
# - legacy flags (modules/features.nix) come back as `flags`, which hosts.nix
#   passes as the `features` specialArg so hosts can gate `imports` on them.
# - the feature tree (./features): one `feature.<area>.<name>.enable` option
#   per feature, set by the host and the profiles it imports. Selected
#   features are projected into `modules.<class>` in tree order, for the
#   factories to append. No downstream module sees the selection.
#
# tree     [ { name = area; value = [ { name; value = descriptor; } … ]; } … ]
# classes  this host's evaluations, e.g. [ "nixos" "homeManager" ]
# modules  outer modules: the host's features.nix (if any), plus extras
#
# A descriptor is { nixos?, homeManager?, darwin?, requires? }. The resolver
# reads only key presence and `requires`; class values are never forced here,
# so an unselected feature is never evaluated. Every check is enforced: a
# failure throws, so nothing in the result can be read.
lib: {
  tree,
  classes,
  modules,
}: let
  inherit (lib) concatMap filter mkEnableOption mkOption types;

  records = concatMap (area:
    map (f: {
      area = area.name;
      inherit (f) name;
      path = "${area.name}.${f.name}";
      descriptor = f.value;
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

  # Per selected feature: its prerequisites are selected, and it has a module
  # for at least one of this host's classes (ADR-005 D6).
  checks = {config, ...}: let
    on = r: config.feature.${r.area}.${r.name}.enable;
    selected = path: lib.getAttrFromPath (lib.splitString "." path ++ ["enable"]) config.feature;
  in {
    assertions = concatMap (r:
      lib.optionals (on r) (
        map (p: {
          assertion = selected p;
          message = "feature.${r.path} requires feature.${p}, which is not selected";
        }) (r.descriptor.requires or [])
        ++ [
          {
            assertion = lib.any (c: r.descriptor ? ${c}) classes;
            message = "feature.${r.path} is selected but has no module for this host's evaluations (${lib.concatStringsSep ", " classes})";
          }
        ]
      ))
    records;
  };

  inherit (lib.evalModules {modules = [./modules/features.nix options checks] ++ modules;}) config;

  paths = map (r: r.path) records;
  unique = lib.allUnique (map (a: a.name) tree) && lib.allUnique paths;
  unknown = concatMap (r:
    map (p: "unknown feature ${p} in ${r.path}.requires")
    (filter (p: !lib.elem p paths) (r.descriptor.requires or [])))
  records;
  failed = filter (a: !a.assertion) config.assertions;
  selected = filter (r: config.feature.${r.area}.${r.name}.enable) records;

  # _file names the feature in error messages; imports never forces the value.
  project = class:
    map (r: {
      _file = "features/${r.area}/${r.name}#${class}";
      imports = [r.descriptor.${class}];
    })
    (filter (r: r.descriptor ? ${class}) selected);
in
  if !unique
  then throw "feature tree has a duplicate area or feature name"
  else if unknown != []
  then throw (lib.concatStringsSep "\n" unknown)
  else if failed != []
  then throw "feature selection failed:\n${lib.concatMapStrings (a: "- ${a.message}\n") failed}"
  else {
    flags = removeAttrs config ["feature" "assertions"];
    modules = lib.genAttrs ["nixos" "homeManager" "darwin"] project;
  }
