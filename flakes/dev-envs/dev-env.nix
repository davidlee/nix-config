# The project's env, as stated by packages.<system>.dev-tools.passthru.devEnv
# (design § The project's env). `errors` is the pure validator: one string per
# refusal. `checkDevEnv` throws once on any, and degrades an absent devEnv to nothing.
#
# `jails` declares jails of the project's own (nemesis:SL-026, nemesis:DEC-235):
#
#   jails.<name> = {
#     agent = "pi";                  # a harness dev-envs maps to a maker
#     network = "offline";           # the only one: the gateway and the forwards
#     mounts = [ { from; to; mode; } ];   # binds into an otherwise empty jail
#     forwards = [ { port; socket; } ];   # in-jail 127.0.0.1:port -> a jail socket
#   };
#
# A mount's `from` is relative to the launch directory, or `$VAR` / `$VAR/path`,
# expanded when the jail starts (nemesis:ASM-005); `to` is an absolute jail
# path, `~` being the jail's home; `mode` is ro or rw. This file interprets the
# vocabulary; flake.nix builds `jailed-<name>` from it, and its check variant
# `jailed-<name>-check` (so no name may end in -check).
let
  allowedKeys = ["env" "hostEnv" "outerGitDir" "jails"];
  jailKeys = ["agent" "network" "mounts" "forwards"];
  mountKeys = ["from" "to" "mode"];
  forwardKeys = ["port" "socket"];
  bindFlags = {
    ro = "--ro-bind";
    rw = "--bind";
  };
  noEnv = {
    env = {};
    hostEnv = [];
    jails = {};
  };
  # [NAME REST] for `$NAME` or `$NAME/rest` (REST null without it), else null.
  varPath = builtins.match "[$]([A-Za-z_][A-Za-z0-9_]*)(/.*)?";
in rec {
  # Every name the host layers own, in jails or in host shells alone.
  hostNames = hostDevEnv: builtins.attrNames (hostDevEnv.env // hostDevEnv.hostOnlyEnv);

  # One string per refusal in a `jails` attrset, each naming its field.
  jailErrors = {
    lib,
    jailAgents,
    reservedJails,
  }: jails: let
    climbs = p: lib.elem ".." (lib.splitString "/" p);
    unknownKeys = where: allowed: v:
      map (k: "unknown key `${where}.${k}` (allowed: ${toString allowed})")
      (lib.subtractLists allowed (lib.attrNames v));
    fromOk = from:
      lib.isString from
      && from != ""
      && !climbs from
      && (
        if lib.hasPrefix "$" from
        then varPath from != null
        else !lib.hasPrefix "/" from
      );
    toOk = to:
      lib.isString to
      && !climbs to
      && (to == "~" || lib.hasPrefix "~/" to || lib.hasPrefix "/" to);
    mountErrors = where: m:
      if !lib.isAttrs m
      then ["`${where}` must be an attrset { from; to; mode; }"]
      else
        unknownKeys where mountKeys m
        ++ lib.optional (!fromOk (m.from or null)) "`${where}.from` must be a path relative to the launch directory, `$VAR` or `$VAR/path`"
        ++ lib.optional (!toOk (m.to or null)) "`${where}.to` must be an absolute jail path, `~` or `~/path`"
        ++ lib.optional (!lib.elem (m.mode or null) (lib.attrNames bindFlags)) "`${where}.mode` must be \"ro\" or \"rw\"";
    forwardErrors = where: f:
      if !lib.isAttrs f
      then ["`${where}` must be an attrset { port; socket; }"]
      else let
        port = f.port or null;
        socket = f.socket or null;
      in
        unknownKeys where forwardKeys f
        ++ lib.optional (!(lib.isInt port && port > 0 && port < 65536)) "`${where}.port` must be an integer port"
        ++ lib.optional (!(lib.isString socket && lib.hasPrefix "/" socket && !climbs socket)) "`${where}.socket` must be an absolute jail path";
    listErrors = where: check: xs:
      if !lib.isList xs
      then ["`${where}` must be a list"]
      else lib.concatLists (lib.imap0 (i: check "${where}[${toString i}]") xs);
    declErrors = name: d: let
      where = "jails.${name}";
    in
      lib.optional (builtins.match "[A-Za-z0-9][A-Za-z0-9._-]*" name == null) "`${where}`: a jail's name must match [A-Za-z0-9][A-Za-z0-9._-]*"
      ++ lib.optional (lib.elem name reservedJails) "`${where}` would shadow dev-envs' own jailed-${name}"
      # Every declaration also yields jailed-<name>-check (nemesis:SL-026, RV-107 F-14).
      ++ lib.optional (lib.hasSuffix "-check" name) "`${where}`: a jail's name must not end in -check (dev-envs builds jailed-<name>-check from each declaration)"
      ++ (
        if !lib.isAttrs d
        then ["`${where}` must be an attrset { agent; network; mounts; forwards; }"]
        else
          unknownKeys where jailKeys d
          ++ lib.optional (!lib.elem (d.agent or null) jailAgents) "`${where}.agent` must be one of: ${toString jailAgents}"
          ++ lib.optional ((d.network or null) != "offline") "`${where}.network` must be \"offline\""
          ++ listErrors "${where}.mounts" mountErrors (d.mounts or [])
          ++ listErrors "${where}.forwards" forwardErrors (d.forwards or [])
      );
  in
    if lib.isAttrs jails
    then lib.concatLists (lib.mapAttrsToList declErrors jails)
    else ["`jails` must be an attrset of declarations"];

  # A valid declared mount as one bwrap bind: three shell words the launcher
  # expands when the jail starts (nemesis:ASM-005). `from` lands under "$PWD"
  # or its variable, `~` in `to` is "$HOME" (the jail's home is at the host's
  # path); every literal part is quoted, so each stays one word.
  mountArgs = lib: m: let
    var = varPath m.from;
    quoted = s: lib.optionalString (s != null) (lib.escapeShellArg s);
    from =
      if var == null
      then "\"$PWD\"/" + lib.escapeShellArg m.from
      else "\"$" + lib.elemAt var 0 + "\"" + quoted (lib.elemAt var 1);
    to =
      if lib.hasPrefix "~" m.to
      then "\"$HOME\"" + quoted (lib.removePrefix "~" m.to)
      else lib.escapeShellArg m.to;
  in "${bindFlags.${m.mode}} ${from} ${to}";

  errors = {
    lib,
    hostNames,
    jailAgents,
    reservedJails,
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
    lib.optional (!isSet) "must be an attrset { env; hostEnv; outerGitDir; jails; }"
    ++ map (k: "unknown key `${k}` (allowed: ${toString allowedKeys})") unknown
    ++ lib.optional (!envOk) "`env` must be an attrset of strings"
    ++ map (n: "`env.${n}` must be a string") badValues
    ++ lib.optional (!hostEnvOk) "`hostEnv` must be a list of strings"
    ++ lib.optional (!outerGitDirOk) "`outerGitDir` must be a bare directory name"
    ++ map (n: "`${n}` is not a valid POSIX name") (lib.filter (n: !lib.isValidPosixName n) names)
    ++ map (n: "`${n}` is owned by the host's env list: do not restate it")
    (lib.filter (n: lib.elem n hostNames) names)
    ++ lib.optionals (isSet && devEnv ? jails) (jailErrors {inherit lib jailAgents reservedJails;} devEnv.jails);

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
