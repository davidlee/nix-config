# Builds one of the gateway's Python scripts with configuration baked in
# (design SL-011 sec-2, sec-4): the text of ./<name> with its shebang pointed
# at `python`'s interpreter and each `NAME = …` line for NAME in `values`
# replaced by `NAME = <toJSON value>` (a valid Python literal for strings,
# lists and string-valued attrsets). The sources keep their defaults, so the
# tests can run them unbaked. Evaluation fails, naming the script, unless the
# shebang is there and every NAME matches exactly one line; the build fails
# unless the result parses (ast, not py_compile: no __pycache__).
{
  pkgs,
  lib,
}: name: python: values: let
  src = ./. + "/${name}";
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
    pkgs.writeTextFile {
      inherit name;
      executable = true;
      text = lib.concatStringsSep "\n" (["#!${python.interpreter}"] ++ map rewrite (lib.tail lines));
      checkPhase = ''
        ${pkgs.python3.interpreter} -c 'import ast, sys; ast.parse(open(sys.argv[1]).read())' "$target"
      '';
    }
