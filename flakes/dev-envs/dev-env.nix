# The project's env, as stated by packages.<system>.dev-tools.passthru.devEnv
# (design § The project's env). `errors` is the pure validator: one string per
# refusal. `checkDevEnv` throws once on any, and degrades an absent devEnv to nothing.
let
  allowedKeys = ["env" "hostEnv"];
  noEnv = {
    env = {};
    hostEnv = [];
  };
in rec {
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
    names = lib.optionals envOk (lib.attrNames env) ++ lib.optionals hostEnvOk hostEnv;
  in
    lib.optional (!isSet) "must be an attrset { env; hostEnv; }"
    ++ map (k: "unknown key `${k}` (allowed: ${toString allowedKeys})") unknown
    ++ lib.optional (!envOk) "`env` must be an attrset of strings"
    ++ map (n: "`env.${n}` must be a string") badValues
    ++ lib.optional (!hostEnvOk) "`hostEnv` must be a list of strings"
    ++ map (n: "`${n}` is not a valid POSIX name") (lib.filter (n: !lib.isValidPosixName n) names)
    ++ map (n: "`${n}` is owned by the host's env list: do not restate it")
    (lib.filter (n: lib.elem n hostNames) names);

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
