# Cases for dev-env.nix: one per refusal row of design § The project's env,
# plus the degrade and the valid case. Each refusal must name its key; names are
# checked with lib.isValidPosixName, and checkDevEnv is the throwing wrapper.
{
  pkgs,
  devEnvLib,
  hostDevEnv,
}: let
  inherit (pkgs) lib;
  hostNames = devEnvLib.hostNames hostDevEnv;
  # As dev-envs passes them: the agents a declared jail may run, and the names
  # of the jails it builds itself.
  args = {
    inherit lib hostNames;
    jailAgents = ["pi"];
    reservedJails = ["pi" "shell"];
  };
  errors = devEnvLib.errors args;
  checkDevEnv = devEnvLib.checkDevEnv args;

  # A declared jail (nemesis:SL-026), valid; each jail refusal breaks one field.
  probeJail = {
    agent = "pi";
    network = "offline";
    mounts = [
      {
        from = "tools/probe";
        to = "/probe";
        mode = "ro";
      }
      {
        from = "$PROBE_SESSION_DIR";
        to = "/session";
        mode = "rw";
      }
    ];
    forwards = [
      {
        port = 7000;
        socket = "/run/probe/duel.sock";
      }
    ];
  };
  withJail = decl: {jails.probe = decl;};
  withMount = m: withJail (probeJail // {mounts = [m];});
  goodMount = lib.head probeJail.mounts;
  withForward = f: withJail (probeJail // {forwards = [f];});

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
      name = "env name owned by host shells alone";
      devEnv = {env.SCCACHE_SERVER_UDS = "x";};
      needle = "SCCACHE_SERVER_UDS";
    }
    {
      name = "hostEnv name owned by host shells alone";
      devEnv = {hostEnv = ["SCCACHE_SERVER_UDS"];};
      needle = "SCCACHE_SERVER_UDS";
    }
    {
      name = "devEnv not an attrset";
      devEnv = ["A"];
      needle = "must be an attrset { env; hostEnv; outerGitDir; jails; }";
    }
    {
      name = "outerGitDir not a string";
      devEnv = {outerGitDir = 1;};
      needle = "`outerGitDir` must be a bare directory name";
    }
    {
      name = "outerGitDir a path";
      devEnv = {outerGitDir = "a/.cfg";};
      needle = "`outerGitDir` must be a bare directory name";
    }
    {
      name = "outerGitDir climbing out";
      devEnv = {outerGitDir = "..";};
      needle = "`outerGitDir` must be a bare directory name";
    }
    {
      name = "outerGitDir with a shell word";
      devEnv = {outerGitDir = "$HOME";};
      needle = "`outerGitDir` must be a bare directory name";
    }
    {
      name = "jails not an attrset";
      devEnv = {jails = [];};
      needle = "`jails` must be an attrset";
    }
    {
      name = "jail name not a bare name";
      devEnv = {jails."a/b" = probeJail;};
      needle = "`jails.a/b`";
    }
    {
      name = "jail name shadows a host jail";
      devEnv = {jails.pi = probeJail;};
      needle = "jailed-pi";
    }
    {
      # Its check variant would be jailed-probe-check (RV-107 F-14).
      name = "jail name ends in -check";
      devEnv = {
        jails = {
          probe = probeJail;
          probe-check = probeJail;
        };
      };
      needle = "`jails.probe-check`: a jail's name must not end in -check";
    }
    {
      name = "jail not an attrset";
      devEnv = withJail "pi";
      needle = "`jails.probe` must be an attrset";
    }
    {
      name = "jail unknown key";
      devEnv = withJail (probeJail // {netwrok = "offline";});
      needle = "`jails.probe.netwrok`";
    }
    {
      name = "jail agent not in the map";
      devEnv = withJail (probeJail // {agent = "claude";});
      needle = "`jails.probe.agent`";
    }
    {
      name = "jail agent absent";
      devEnv = withJail (builtins.removeAttrs probeJail ["agent"]);
      needle = "`jails.probe.agent`";
    }
    {
      name = "jail network not offline";
      devEnv = withJail (probeJail // {network = "research";});
      needle = "`jails.probe.network`";
    }
    {
      name = "mounts not a list";
      devEnv = withJail (probeJail // {mounts = goodMount;});
      needle = "`jails.probe.mounts` must be a list";
    }
    {
      name = "mount unknown key";
      devEnv = withMount (goodMount // {options = "x";});
      needle = "`jails.probe.mounts[0].options`";
    }
    {
      name = "mount without from";
      devEnv = withMount (builtins.removeAttrs goodMount ["from"]);
      needle = "`jails.probe.mounts[0].from`";
    }
    {
      name = "mount from an absolute host path";
      devEnv = withMount (goodMount // {from = "/etc";});
      needle = "`jails.probe.mounts[0].from`";
    }
    {
      name = "mount from climbing out";
      devEnv = withMount (goodMount // {from = "tools/../..";});
      needle = "`jails.probe.mounts[0].from`";
    }
    {
      name = "mount from a malformed variable";
      devEnv = withMount (goodMount // {from = "$1/x";});
      needle = "`jails.probe.mounts[0].from`";
    }
    {
      name = "mount to a relative path";
      devEnv = withMount (goodMount // {to = "probe";});
      needle = "`jails.probe.mounts[0].to`";
    }
    {
      name = "mount mode not ro or rw";
      devEnv = withMount (goodMount // {mode = "rx";});
      needle = "`jails.probe.mounts[0].mode`";
    }
    {
      name = "forward port not an integer";
      devEnv = withForward {
        port = "7000";
        socket = "/run/probe/duel.sock";
      };
      needle = "`jails.probe.forwards[0].port`";
    }
    {
      name = "forward socket not absolute";
      devEnv = withForward {
        port = 7000;
        socket = "duel.sock";
      };
      needle = "`jails.probe.forwards[0].socket`";
    }
    {
      name = "forward unknown key";
      devEnv = withForward (lib.head probeJail.forwards // {host = "x";});
      needle = "`jails.probe.forwards[0].host`";
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
  withOuterGit = {outerGitDir = ".cfg";};
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
            jails = {};
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
        ok = checkDevEnv valid == valid // {jails = {};};
        detail = "";
      }
      {
        name = "env alone degrades hostEnv";
        ok =
          checkDevEnv {env.A = "1";}
          == {
            env.A = "1";
            hostEnv = [];
            jails = {};
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
            jails = {};
          };
        detail = "";
      }
      {
        name = "outerGitDir is admitted, a dotted name included";
        ok = errors withOuterGit == [];
        detail = "";
      }
      {
        name = "outerGitDir passes through";
        ok = (checkDevEnv withOuterGit).outerGitDir == ".cfg";
        detail = "";
      }
      {
        name = "a declared jail is admitted";
        ok = errors (withJail probeJail) == [];
        detail = "errors: ${builtins.toJSON (errors (withJail probeJail))}";
      }
      {
        name = "a declared jail passes through";
        ok = (checkDevEnv (withJail probeJail)).jails.probe == probeJail;
        detail = "";
      }
      {
        name = "a jail without mounts or forwards is admitted";
        ok =
          errors (withJail {
            agent = "pi";
            network = "offline";
          })
          == [];
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

  # mount -> the three words bwrap gets, @launch@ the launch directory.
  mountCases = [
    {
      mount = goodMount;
      expect = ["--ro-bind" "@launch@/tools/probe" "/probe"];
    }
    {
      mount = {
        from = "$PROBE_SESSION_DIR";
        to = "/session";
        mode = "rw";
      };
      expect = ["--bind" "/var/probe/a session" "/session"];
    }
    {
      mount = {
        from = "$XDG_RUNTIME_DIR/nemesis-probe";
        to = "/run/probe";
        mode = "ro";
      };
      expect = ["--ro-bind" "/run/user/1/nemesis-probe" "/run/probe"];
    }
    {
      mount = {
        from = "tools/probe/pi-mcp.json";
        to = "~/.pi/agent/mcp.json";
        mode = "ro";
      };
      expect = ["--ro-bind" "@launch@/tools/probe/pi-mcp.json" "/home/someone/.pi/agent/mcp.json"];
    }
    {
      mount = {
        from = "a dir/it's $NOT";
        to = "~";
        mode = "rw";
      };
      expect = ["--bind" "@launch@/a dir/it's $NOT" "/home/someone"];
    }
  ];
in
  pkgs.runCommand "dev-env-test" {} (
    if failed == []
    then ''
      # The warning reads a built tree, so it runs here rather than among the cases.
      mkdir -p clean/bin carrying/bin
      touch carrying/bin/doctrine

      (${devEnvLib.doctrineWarning "$PWD/clean"}) 2>clean.err
      if [ -s clean.err ]; then
        echo 'dev-env: FAIL warning on clean dev-tools' >&2
        exit 1
      fi

      (${devEnvLib.doctrineWarning "$PWD/carrying"}) 2>carrying.err
      if ! grep -qF 'flakes:DEC-128' carrying.err; then
        echo 'dev-env: FAIL no warning on dev-tools carrying doctrine' >&2
        exit 1
      fi

      # A declared mount's bind words, expanded as the launcher expands them
      # (nemesis:ASM-005): `from` under the launch directory or its variable,
      # `~` as the jail's home, one word each whatever they hold.
      expands() { # expands EXPECTED-FLAG EXPECTED-FROM EXPECTED-TO WORDS
        local -a got
        set -- "$1" "''${2//@launch@/$launch}" "$3" "$4"
        eval "got=($4)"
        if [ "''${#got[@]}" != 3 ] || [ "''${got[0]}" != "$1" ] || [ "''${got[1]}" != "$2" ] || [ "''${got[2]}" != "$3" ]; then
          echo "dev-env: FAIL mount words '$4' gave: ''${got[*]}" >&2
          exit 1
        fi
      }
      (
        cd "$(mktemp -d)"
        launch=$PWD
        HOME=/home/someone
        PROBE_SESSION_DIR='/var/probe/a session'
        XDG_RUNTIME_DIR=/run/user/1
        ${lib.concatMapStringsSep "\n" (c: "expands ${lib.escapeShellArgs c.expect} ${lib.escapeShellArg (devEnvLib.mountArgs lib c.mount)}") mountCases}
      )

      touch $out
    ''
    else ''
      ${lib.concatMapStringsSep "\n" (c: "echo 'dev-env: FAIL ${c.name}: ${lib.escape ["'"] c.detail}' >&2") failed}
      exit 1
    ''
  )
