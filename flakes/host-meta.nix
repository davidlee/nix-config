# The schema of hosts/<host>/meta.nix (DEC-039): validates one host's meta
# and returns it as plain data, `home` defaulted. A bad meta fails by
# `throw`, naming `file`: an unknown key or a wrong type through the module
# system's own `_file`, a missing option through the error context.
#
#   import ./host-meta.nix lib "hosts/<host>/meta.nix" meta
#
# Strict: option values are lazy, so the result is forced inside the error
# context, or a missing option would be reported without the file.
lib: file: meta: let
  config =
    removeAttrs
    (lib.evalModules {
      modules = [
        {
          options = {
            kind = lib.mkOption {type = lib.types.enum ["nixos" "darwin"];};
            system = lib.mkOption {type = lib.types.str;};
            home = lib.mkOption {
              type = lib.types.bool;
              default = false;
            };
          };
        }
        {
          _file = file;
          config = meta;
        }
      ];
    }).config ["_module"];
in
  builtins.addErrorContext "while validating ${file}" (builtins.deepSeq config config)
