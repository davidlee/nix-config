# A jail's workspace deps as bwrap binds: each sibling repo at
# /workspace/<basename>, `ro` paths read-only and `rw` paths read-write
# (DEC-081). Refuses a relative path, and a destination shared within or
# across the two lists. The refusals fire when the options are forced, which
# building the jail does.
{
  lib,
  unsafe-add-raw-args,
}: {
  name, # the jail's name, for refusals
  ro,
  rw,
  # Machine-local deps can be supplied at eval time via the env vars
  # JAIL_WORKSPACE_DEPS (ro) and JAIL_WORKSPACE_DEPS_RW (rw), newline- or
  # colon-separated absolute paths. Requires impure eval (`--impure`);
  # under pure eval getEnv returns "" -> empty -> no-op. Merged with and
  # deduped against the static list of the same mode, so a flake can ship
  # portable defaults while each machine adds its own paths via .envrc.
  # false: neither variable is read, so the jail's eval ignores the
  # environment.
  fromEnv,
}: let
  envDeps = var:
    lib.optionals fromEnv (
      lib.filter (s: s != "") (
        lib.splitString ":" (
          builtins.replaceStrings ["\n"] [":"] (builtins.getEnv var)
        )
      )
    );
  stripTrailingSlashes = dep:
    if dep != "/" && lib.hasSuffix "/" dep
    then stripTrailingSlashes (lib.removeSuffix "/" dep)
    else dep;
  # One mode's deps, static and env merged, as bind specs tagged with it.
  bindSpecsFor = mode: static: var:
    map (dep: let
      source = stripTrailingSlashes dep;
    in {
      inherit mode source;
      destination = "/workspace/${builtins.baseNameOf source}";
    }) (lib.unique (static ++ envDeps var));
  # Both modes in one list: the guards below span it, so a destination is
  # refused when shared within or across the lists.
  specs =
    bindSpecsFor "ro" ro "JAIL_WORKSPACE_DEPS"
    ++ bindSpecsFor "rw" rw "JAIL_WORKSPACE_DEPS_RW";
  relative = map (bind: bind.source) (
    lib.filter (bind: !(lib.hasPrefix "/" bind.source)) specs
  );
  duplicates =
    lib.filterAttrs (
      _: binds: builtins.length binds > 1
    )
    (lib.groupBy (bind: bind.destination) specs);
  duplicatesMessage = lib.concatStringsSep "; " (
    lib.mapAttrsToList (
      destination: binds: "${destination} <- ${lib.concatStringsSep ", " (map (bind: bind.source) binds)}"
    )
    duplicates
  );
  # jail.nix builds launchers with ShellCheck enabled. Its SC2016 check
  # rejects a dollar followed by a name inside the single quotes emitted
  # by escapeShellArgs, even though that is precisely what keeps it
  # literal. Split dollars into an adjacent, isolated quoted segment:
  # 'foo$dollar' becomes 'foo'"$"'dollar' with the same argv value.
  escapeBindArgs = args: builtins.replaceStrings ["$"] ["'\"$\"'"] (lib.escapeShellArgs args);
  bindFlags = {
    ro = "--ro-bind";
    rw = "--bind";
  };
in
  assert relative
  == []
  || throw "Workspace dependencies for jailed-${name} must be absolute paths: ${lib.concatStringsSep ", " relative}";
  assert duplicates
  == {}
  || throw "Workspace dependencies for jailed-${name} have duplicate destinations: ${duplicatesMessage}";
    map (
      bind:
        unsafe-add-raw-args (escapeBindArgs [
          bindFlags.${bind.mode}
          bind.source
          bind.destination
        ])
    )
    specs
