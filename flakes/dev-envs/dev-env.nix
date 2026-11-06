# The project's env, as stated by packages.<system>.dev-tools.passthru.devEnv
# (design § The project's env). `errors` is the pure validator: one string per
# refusal. `checkDevEnv` throws once on any, and degrades an absent devEnv to nothing.
let
  allowedKeys = ["env" "hostEnv" "outerGitDir"];
  noEnv = {
    env = {};
    hostEnv = [];
  };
in rec {
  # Every name the host layers own, in jails or in host shells alone.
  hostNames = hostDevEnv: builtins.attrNames (hostDevEnv.env // hostDevEnv.hostOnlyEnv);

  errors = {
    lib,
    hostNames,
  }: devEnv: let
    isSet = lib.isAttrs devEnv;
    unknown = lib.optionals isSet (lib.subtractLists allowedKeys (lib.attrNames devEnv));
    env =
      if isSet
      then devEnv.env or {}
      else {};
    hostEnv =
      if isSet
      then devEnv.hostEnv or []
      else [];
    envOk = lib.isAttrs env;
    badValues = lib.optionals envOk (lib.filter (n: !lib.isString env.${n}) (lib.attrNames env));
    hostEnvOk = lib.isList hostEnv && lib.all lib.isString hostEnv;
    outerGitDirOk =
      !(isSet && devEnv ? outerGitDir)
      || (lib.isString devEnv.outerGitDir
        && builtins.match "[.]?[A-Za-z0-9][A-Za-z0-9._-]*" devEnv.outerGitDir != null);
    names = lib.optionals envOk (lib.attrNames env) ++ lib.optionals hostEnvOk hostEnv;
  in
    lib.optional (!isSet) "must be an attrset { env; hostEnv; outerGitDir; }"
    ++ map (k: "unknown key `${k}` (allowed: ${toString allowedKeys})") unknown
    ++ lib.optional (!envOk) "`env` must be an attrset of strings"
    ++ map (n: "`env.${n}` must be a string") badValues
    ++ lib.optional (!hostEnvOk) "`hostEnv` must be a list of strings"
    ++ lib.optional (!outerGitDirOk) "`outerGitDir` must be a bare directory name"
    ++ map (n: "`${n}` is not a valid POSIX name") (lib.filter (n: !lib.isValidPosixName n) names)
    ++ map (n: "`${n}` is owned by the host's env list: do not restate it")
    (lib.filter (n: lib.elem n hostNames) names);

  # Shell code, for a shell's entry: what dev-tools holds is known only once built.
  # Warns and does not refuse, so a project mid-move keeps its shell (flakes:DEC-128).
  doctrineWarning = devTools: ''
    if [ -e ${devTools}/bin/doctrine ]; then
      cat >&2 <<'WARNING'

    !!! dev-envs: THIS PROJECT'S dev-tools CARRIES DOCTRINE !!!
    It shadows the host install in every jail and form here, so agents run a
    Doctrine pinned by this project's lock, not the one the host runs.
    Move it to capsule-tools, point the fleet target there, then drop it from
    dev-tools (flakes:DEC-128).

    WARNING
    fi
  '';

  checkDevEnv = args: devEnv: let
    es = errors args devEnv;
  in
    if es == []
    then noEnv // devEnv
    else
      throw ''
        dev-envs: packages.<system>.dev-tools.passthru.devEnv is invalid:
        ${args.lib.concatMapStringsSep "\n" (e: "  - " + e) es}
      '';
}
