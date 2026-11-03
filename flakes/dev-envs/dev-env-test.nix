# Cases for dev-env.nix: one per refusal row of design § The project's env,
# plus the degrade and the valid case. Each refusal must name its key; names are
# checked with lib.isValidPosixName, and checkDevEnv is the throwing wrapper.
{
  pkgs,
  devEnvLib,
}: let
  inherit (pkgs) lib;
  hostNames = ["RUSTC_WRAPPER"];
  errors = devEnvLib.errors {inherit lib hostNames;};
  checkDevEnv = devEnvLib.checkDevEnv {inherit lib hostNames;};

  # name, input, and the text every error message must contain.
  refusals = [
    {
      name = "unknown key";
      devEnv = {envv = {};};
      needle = "envv";
    }
    {
      name = "env not an attrset";
      devEnv = {env = ["A"];};
      needle = "`env` must be an attrset";
    }
    {
      name = "env value not a string";
      devEnv = {env.A = 1;};
      needle = "`env.A` must be a string";
    }
    {
      name = "invalid name in env";
      devEnv = {env."A-B" = "x";};
      needle = "A-B";
    }
    {
      name = "invalid name in hostEnv";
      devEnv = {hostEnv = ["1BAD"];};
      needle = "1BAD";
    }
    {
      name = "hostEnv not a list of strings";
      devEnv = {hostEnv = "A";};
      needle = "`hostEnv` must be a list";
    }
    {
      name = "env name owned by host";
      devEnv = {env.RUSTC_WRAPPER = "x";};
      needle = "RUSTC_WRAPPER";
    }
    {
      name = "hostEnv name owned by host";
      devEnv = {hostEnv = ["RUSTC_WRAPPER"];};
      needle = "RUSTC_WRAPPER";
    }
    {
      name = "devEnv not an attrset";
      devEnv = ["A"];
      needle = "must be an attrset { env; hostEnv; }";
    }
  ];

  refusalCase = r: let
    es = errors r.devEnv;
  in {
    inherit (r) name;
    ok = es != [] && lib.all (lib.hasInfix r.needle) es;
    detail = "errors: ${builtins.toJSON es}";
  };

  valid = {
    env.A = "1";
    hostEnv = ["B"];
  };
  cases =
    map refusalCase refusals
    ++ [
      {
        name = "degrade";
        ok =
          checkDevEnv {}
          == {
            env = {};
            hostEnv = [];
          };
        detail = "";
      }
      {
        name = "valid has no errors";
        ok = errors valid == [];
        detail = "";
      }
      {
        name = "valid passes through";
        ok = checkDevEnv valid == valid;
        detail = "";
      }
      {
        name = "env alone degrades hostEnv";
        ok =
          checkDevEnv {env.A = "1";}
          == {
            env.A = "1";
            hostEnv = [];
          };
        detail = "";
      }
      {
        name = "hostEnv alone degrades env";
        ok =
          checkDevEnv {hostEnv = ["B"];}
          == {
            env = {};
            hostEnv = ["B"];
          };
        detail = "";
      }
      {
        name = "check throws on a refusal";
        ok = let
          r = builtins.tryEval (builtins.deepSeq (checkDevEnv {envv = {};}) true);
        in
          !r.success;
        detail = "check did not throw";
      }
    ];
  failed = lib.filter (c: !c.ok) cases;
in
  pkgs.runCommand "dev-env-test" {} (
    if failed == []
    then "touch $out"
    else ''
      ${lib.concatMapStringsSep "\n" (c: "echo 'dev-env: FAIL ${c.name}: ${lib.escape ["'"] c.detail}' >&2") failed}
      exit 1
    ''
  )
