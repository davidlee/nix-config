`lib.callPackageWith` (nixpkgs `lib/customisation.nix`) passes each function
argument that names an attribute of the package set — including arguments with
defaults. So an overlay adding a non-package attribute with a common name
silently overrides package defaults.

Observed (SL-004, RV-009 F-2): an overlay adding `pkgs.stable` (a nixpkgs-24.11
set) makes `kicad` fail with "expected a Boolean but found a set";
`kicad/package.nix`, `kicad/base.nix` and `guile-cairo` declare `stable ? true`.

Prefer, for values modules consume: `_module.args.<name>` set in a module
(lazy; not usable inside `imports`). If it must live in pkgs, grep the pinned
nixpkgs `pkgs/` for the name as a function argument first.

Related module-system gotcha: `evalModules` strips `_module` from `config`
(`lib/modules.nix`), and a `specialArgs.pkgs` shadows `_module.args.pkgs`, so a
check that wants "the pkgs modules see" must read `pkgs` inside a probe module,
not `config._module.args.pkgs` (RV-009 F-3).
