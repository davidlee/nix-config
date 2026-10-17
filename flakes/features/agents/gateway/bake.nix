# Bakes configuration into one of the gateway's Python scripts (design SL-011
# sec-2, sec-4): the text of `src` with its shebang pointed at `interpreter`
# and each `NAME = …` line for NAME in `values` replaced by
# `NAME = <toJSON value>` (a valid Python literal for strings, lists and
# string-valued attrsets). The sources keep their defaults, so the tests run
# them unbaked. Evaluation fails, naming the script, unless the shebang is
# there and every NAME matches exactly one line.
{lib}: {
  src,
  interpreter,
  values,
}: let
  lines = lib.splitString "\n" (builtins.readFile src);
  assigns = name: lib.hasPrefix "${name} = ";
  checked = name: let
    n = lib.count (assigns name) lines;
  in
    n == 1 || throw "bake: ${toString src} has ${toString n} `${name} = ` lines, want 1";
  rewrite = line: let
    name = lib.findFirst (name: assigns name line) null (lib.attrNames values);
  in
    if name == null
    then line
    else "${name} = ${builtins.toJSON values.${name}}";
in
  assert lib.hasPrefix "#!" (lib.head lines) || throw "bake: ${toString src} has no shebang";
  assert lib.all checked (lib.attrNames values);
    lib.concatStringsSep "\n" (["#!${interpreter}"] ++ map rewrite (lib.tail lines))
