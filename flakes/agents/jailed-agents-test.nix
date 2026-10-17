{
  pkgs,
  jail-nix,
}: let
  inherit (pkgs) lib;
  system = pkgs.stdenv.hostPlatform.system;

  fakeAgent = name:
    pkgs.writeShellScriptBin name ''
      exit 0
    '';
  fakeAgents = {
    packages.${system} = {
      pi = fakeAgent "pi";
      crush = fakeAgent "crush";
      opencode = fakeAgent "opencode";
      claude-code = fakeAgent "claude";
      codex = fakeAgent "codex";
      gemini-cli = fakeAgent "gemini";
    };
  };
  apiKeyOpRefs = {
    OPENAI_API_KEY = "op://Test/OpenAI/credential";
    OPENROUTER_API_KEY = "op://Test/OpenRouter/credential";
  };
  mkAgents = extra:
    import ./jailed-agents.nix (
      {
        inherit pkgs jail-nix apiKeyOpRefs;
        llm-agents = fakeAgents;
      }
      // extra
    );
  agents = mkAgents {};
  customIdentityAgents = mkAgents {
    gitIdentity = {
      authorName = "Test author";
      authorEmail = "author@example.test";
      committerName = "Test committer";
      committerEmail = "committer@example.test";
    };
  };
  lazySecretAgents = mkAgents {
    apiKeyOpRefs.BROKEN_API_KEY = throw "secret refs must remain lazy";
  };

  inner = profile: args:
    agents.makeJailedZsh (
      {
        inherit profile;
        useOpEnv = false;
        passApiKeysFromEnv = false;
      }
      // args
    );
  specDev = inner "specDev" {};
  research = inner "research" {};
  offline = inner "offline" {};
  sshPushAllowed = inner "specDev" {blockSshGitPush = false;};
  gitUnguarded = inner "specDev" {guardGit = false;};
  legacySshPushAllowed = inner "specDev" {blockGitPush = false;};
  customIdentity = customIdentityAgents.makeJailedZsh {
    profile = "specDev";
    useOpEnv = false;
    passApiKeysFromEnv = false;
  };
  selectedKeyOuter = agents.makeJailedPi {
    apiKeys = ["OPENROUTER_API_KEY"];
    passApiKeysFromEnv = false;
  };
  selectedKeyFromEnv = agents.makeJailedPi {
    apiKeys = ["OPENROUTER_API_KEY"];
    useOpEnv = false;
    passApiKeysFromEnv = true;
  };
  noKeys = agents.makeJailedPi {
    apiKeys = [];
    useOpEnv = true;
    passApiKeysFromEnv = true;
  };
  noSecretMachinery = lazySecretAgents.makeJailedPi {
    useOpEnv = false;
    passApiKeysFromEnv = false;
  };
  knownSubagent = agents.makeJailedAgent {
    name = "custom";
    agent = fakeAgent "custom";
    subagents = ["pi"];
    maxSubagentDepth = 2;
    useOpEnv = false;
    passApiKeysFromEnv = false;
  };
  dangerousWorkspacePath = "/tmp/work dep/quo'te$dollar;semi";
  workspace = inner "specDev" {
    workspaceDeps = ["/tmp/normal/" dangerousWorkspacePath];
  };
  expectedWorkspaceBind = pkgs.writeText "expected-workspace-bind" (
    builtins.replaceStrings ["$"] ["'\"$\"'"] (
      lib.escapeShellArgs [
        "--bind"
        dangerousWorkspacePath
        "/workspace/quo'te$dollar;semi"
      ]
    )
  );

  # Real bwrap needs user namespaces, which the build sandbox lacks. This
  # stand-in, under bwrap's own name and store slot, records what bwrap
  # would start with: its initial environ (/proc/$$/environ, as bwrap's
  # /proc/1/environ reads inside the jail), its argv, and the `--args`
  # descriptors. No PATH: it must work from an empty environment.
  fakeBwrap = pkgs.writeShellScriptBin "bwrap" ''
    tr=${pkgs.coreutils}/bin/tr
    "$tr" '\0' '\n' < /proc/$$/environ > bwrap-environ
    printf '%s\n' "$@" > bwrap-argv
    for fd in 21 22; do
      if [ -e /dev/fd/$fd ]; then "$tr" '\0' '\n' < /dev/fd/$fd > bwrap-args-$fd; fi
    done
  '';
  fakeBwrapAgents = mkAgents {
    pkgs = pkgs.extend (_: _: {bubblewrap = fakeBwrap;});
  };
  probeKeys = fakeBwrapAgents.makeJailedPi {
    apiKeys = ["OPENROUTER_API_KEY"];
    useOpEnv = false;
    passApiKeysFromEnv = true;
  };
  probeGateway = fakeBwrapAgents.makeJailedPi {gateway = gw;};

  failsToEvaluate = value: !(builtins.tryEval value.drvPath).success;
  unknownApiKeyFails = failsToEvaluate (agents.makeJailedPi {
    apiKeys = ["NOT_CONFIGURED"];
    useOpEnv = false;
  });
  unknownSubagentFails = failsToEvaluate (agents.makeJailedAgent {
    name = "custom";
    agent = fakeAgent "custom";
    subagents = ["not-an-agent"];
    useOpEnv = false;
  });
  zeroDepthFails = failsToEvaluate (agents.makeJailedAgent {
    name = "custom";
    agent = fakeAgent "custom";
    subagents = ["pi"];
    maxSubagentDepth = 0;
    useOpEnv = false;
  });
  relativeWorkspaceFails = failsToEvaluate (inner "specDev" {
    workspaceDeps = ["relative/path"];
  });
  duplicateWorkspaceFails = failsToEvaluate (inner "specDev" {
    workspaceDeps = ["/tmp/one/shared" "/tmp/two/shared"];
  });

  # Gateway mode. runDirectory cannot exist in the build sandbox, so the
  # outer wrapper's checks are observable without reaching bwrap.
  gw = {
    keyFile = "$HOME/.config/llm-gateway/keys/pi";
    url = "http://127.0.0.1:4000/v1";
    runDirectory = "/nonexistent/llm-gateway";
  };
  # Profile defaults (useOpEnv = true): gateway wins over the op wrapper.
  gatewayJail = agents.makeJailedPi {gateway = gw;};
  # Gateway mode never forces apiKeyOpRefs.
  gatewayLazySecrets = lazySecretAgents.makeJailedPi {gateway = gw;};
  # Each refusal is paired with a twin that differs only in the property
  # under test: gatewayEmptyKeys for the keys, gatewayJail for the shape.
  gatewayEmptyKeys = agents.makeJailedPi {
    gateway = gw;
    apiKeys = [];
  };
  gatewayWithKeysFails = failsToEvaluate (agents.makeJailedPi {
    gateway = gw;
    apiKeys = ["OPENAI_API_KEY"];
  });
  gatewayMissingKeyFileFails = failsToEvaluate (agents.makeJailedPi {
    gateway = builtins.removeAttrs gw ["keyFile"];
  });
  gatewayUnknownAttrFails = failsToEvaluate (agents.makeJailedPi {
    gateway = gw // {socket = "/nonexistent/llm-gateway/api.sock";};
  });
in
  assert knownSubagent.drvPath != "";
  assert noSecretMachinery.drvPath != "";
  assert unknownApiKeyFails;
  assert unknownSubagentFails;
  assert zeroDepthFails;
  assert relativeWorkspaceFails;
  assert duplicateWorkspaceFails;
  assert gatewayLazySecrets.drvPath != "";
  assert gatewayEmptyKeys.drvPath != "";
  assert gatewayWithKeysFails;
  assert gatewayMissingKeyFileFails;
  assert gatewayUnknownAttrFails;
    pkgs.runCommand "jailed-agents-policy-tests" {
      nativeBuildInputs = [pkgs.gnugrep pkgs.coreutils];
    } ''
      # A bare `! cmd` never trips errexit (bash exempts negated pipelines),
      # so it cannot fail the build. Every negative assertion uses this.
      refute() {
        if "$@"; then
          echo "refute: holds, expected not to: $*" >&2
          exit 1
        fi
      }

      # The inner launcher a gateway wrapper execs.
      gateway_inner_of() {
        sed -n 's|^exec \(/nix/store/[^ ]*-jailed-pi/bin/jailed-pi\) .*|\1|p' "$1"
      }

      spec=${specDev}/bin/jailed-zsh
      research=${research}/bin/jailed-zsh
      offline=${offline}/bin/jailed-zsh

      refute grep -Fq -- '--unshare-net' "$spec"
      refute grep -Fq -- '--unshare-net' "$research"
      grep -Fq -- '--unshare-net' "$offline"
      grep -Fq -- 'home/agent' "$spec"
      grep -Fq -- 'home/agent-research' "$research"
      grep -Fq -- 'home/agent-offline' "$offline"

      grep -Fq -- 'GIT_SSH_COMMAND' "$spec"
      refute grep -Fq -- 'GIT_SSH_COMMAND' ${sshPushAllowed}/bin/jailed-zsh
      refute grep -Fq -- 'GIT_SSH_COMMAND' ${legacySshPushAllowed}/bin/jailed-zsh
      grep -Fq -- 'GIT_AUTHOR_NAME' "$spec"
      grep -Fq -- "'Jailed agent'" "$spec"
      grep -Fq -- 'jailed-agent@localhost' "$spec"
      grep -Fq -- "'Test author'" ${customIdentity}/bin/jailed-zsh
      grep -Fq -- 'committer@example.test' ${customIdentity}/bin/jailed-zsh

      # Every profile gets the guarded git, and exactly one git: the guard
      # replaces git on PATH rather than racing it for first place.
      for launcher in "$spec" "$research" "$offline"; do
        grep -q -- '--setenv PATH [^ ]*-git-guarded/bin' "$launcher"
        refute grep -q -- '--setenv PATH [^ ]*-git-[0-9][^ /]*/bin' "$launcher"
      done
      unguarded=${gitUnguarded}/bin/jailed-zsh
      refute grep -Fq -- '-git-guarded' "$unguarded"
      grep -Fq -- '${pkgs.git}/bin' "$unguarded"

      # Behaviour: run the probes against the guarded git from the launcher.
      guarded_bin="$(grep -o '/nix/store/[^ :]*-git-guarded/bin' "$spec" | head -1)"
      HOME="$TMPDIR/probe-home" PATH="$guarded_bin:$PATH" \
        sh ${./git-guard.test.sh}

      # Host excludes: mounted read-only at git's default excludes path,
      # after (so on top of) the persisted home bind.
      for launcher in "$spec" "$research" "$offline"; do
        home_at="$(grep -bo -- '--bind ~/.local/share/jail.nix/home/[^ ]* ~' "$launcher" | cut -d: -f1)"
        excl_at="$(grep -bo -- '--ro-bind-try "$([^)]*-host-git-excludes-file)" ~/.config/git/ignore' "$launcher" | cut -d: -f1)"
        test -n "$home_at" && test -n "$excl_at" && test "$excl_at" -gt "$home_at"
      done

      # Behaviour: the resolver mirrors git's own lookup.
      resolver="$(grep -o '/nix/store/[^ )]*-host-git-excludes-file' "$spec" | head -1)"
      fake="$TMPDIR/fake-home"
      mkdir -p "$fake"
      test "$(env -i HOME="$fake" "$resolver")" = "$fake/.config/git/ignore"
      test "$(env -i HOME="$fake" XDG_CONFIG_HOME="$fake/xdg" "$resolver")" = "$fake/xdg/git/ignore"
      printf '[core]\n  excludesFile = ~/.gitignore_global\n' > "$fake/.gitconfig"
      test "$(env -i HOME="$fake" "$resolver")" = "$fake/.gitignore_global"

      refute grep -Fq -- '/home/david' "$spec"
      refute grep -Fq -- '/run/user/1000' "$spec"

      outer=${selectedKeyOuter}/bin/jailed-pi
      grep -Fqx -- 'op=/run/wrappers/bin/op' "$outer"
      grep -Fq -- 'exec "$op" run --no-masking --env-file=' "$outer"
      env_file="$(sed -n 's/.*--env-file=\([^ ]*\).*/\1/p' "$outer")"
      test -n "$env_file"
      grep -Fqx -- 'OPENROUTER_API_KEY=op://Test/OpenRouter/credential' "$env_file"
      refute grep -Fq -- 'OPENAI_API_KEY' "$env_file"
      inner_path="$(sed -n 's|.*\(/nix/store/[^ ]*-jailed-pi\)/bin/jailed-pi.*|\1|p' "$outer")"
      test -n "$inner_path"
      refute grep -Fq -- 'OPENROUTER_API_KEY' "$inner_path/bin/jailed-pi"

      forwarded=${selectedKeyFromEnv}/bin/jailed-pi
      refute grep -Fq -- 'op run' "$forwarded"
      grep -Fq -- 'OPENROUTER_API_KEY' "$forwarded"
      refute grep -Fq -- 'OPENAI_API_KEY' "$forwarded"

      # Keys reach the jail over `--args FD`, never over bwrap's argv:
      # /proc/<pid>/cmdline is mode 444 and /proc is routinely mounted with
      # no hidepid, so an argv-borne secret is readable by every process on
      # the host for the jail's lifetime. Both forms are textually on the
      # same physical line, so assert structurally: strip every process
      # substitution, and no key name may survive into the command line.
      grep -Fq -- '--args 21 21< <(printf' "$forwarded"
      sed 's/<(printf[^)]*)//g' "$forwarded" > "$TMPDIR/argv-only"
      refute grep -Fq -- 'API_KEY' "$TMPDIR/argv-only"

      no_keys=${noKeys}/bin/jailed-pi
      refute grep -Fq -- 'op run' "$no_keys"
      refute grep -Fq -- 'API_KEY' "$no_keys"

      # Gateway mode: no op wrapper and no provider key; the gateway key
      # reaches the jail over its own `--args FD`, read by a shell builtin.
      gw_outer=${gatewayJail}/bin/jailed-pi
      refute grep -Fq -- 'op run' "$gw_outer"
      refute grep -Fq -- '/run/wrappers/bin/op' "$gw_outer"
      gw_inner="$(gateway_inner_of "$gw_outer")"
      test -n "$gw_inner"
      grep -Fq -- '--args 22 22< <(printf' "$gw_inner"
      grep -Fq -- '--setenv LLM_GATEWAY_KEY "$(<' "$gw_inner"
      refute grep -Fq -- 'cat ' "$gw_inner"
      refute grep -Fq -- 'API_KEY' "$gw_inner"
      refute grep -Fq -- '--args 21' "$gw_inner"
      grep -Fq -- '--setenv LLM_GATEWAY_URL ${lib.escapeShellArg gw.url}' "$gw_inner"
      # Argv safety, as for provider keys. The strip stops at the first `)`,
      # which closes the nested `$(<` — after the key's name.
      sed 's/<(printf[^)]*)//g' "$gw_inner" > "$TMPDIR/gw-argv-only"
      refute grep -Fq -- 'LLM_GATEWAY_KEY' "$TMPDIR/gw-argv-only"

      # Behaviour: the outer wrapper fails with the fix, before bwrap.
      export HOME="$TMPDIR/gw-home"
      key_file="$HOME/.config/llm-gateway/keys/pi"
      if "$gw_outer" 2> "$TMPDIR/gw-no-key"; then exit 1; fi
      grep -Fq -- 'llm-gateway issue pi' "$TMPDIR/gw-no-key"
      grep -Fq -- "$key_file" "$TMPDIR/gw-no-key"
      mkdir -p "$(dirname "$key_file")"
      printf 'sk-test-SENTINEL' > "$key_file"
      if "$gw_outer" 2> "$TMPDIR/gw-no-gateway"; then exit 1; fi
      # RV-026 F-7: both causes named: never switched, or the service failing.
      grep -Fq -- 'just system-switch' "$TMPDIR/gw-no-gateway"
      grep -Fq -- 'systemctl status llm-gateway' "$TMPDIR/gw-no-gateway"
      grep -Fq -- 'just gateway-credentials' "$TMPDIR/gw-no-gateway"
      refute grep -Fq -- 'sk-test-SENTINEL' "$TMPDIR/gw-no-gateway"

      # Behaviour: the emitted read expands keyFile at run time and yields
      # the key intact, as one NUL-separated --setenv.
      read_key="$(grep -o "printf '%s\\\\0' --setenv LLM_GATEWAY_KEY \"\$(< \"[^\"]*\")\"" "$gw_inner")"
      test -n "$read_key"
      eval "$read_key" > "$TMPDIR/gw-args"
      printf '%s\0' --setenv LLM_GATEWAY_KEY sk-test-SENTINEL | cmp -s - "$TMPDIR/gw-args"

      # Behaviour: bwrap starts with an EMPTY environment. --clearenv empties
      # only the child's; bwrap's own environ is what it was exec'd with, and
      # bwrap is PID 1 in the jail, where /proc/1/environ is readable. The
      # launch env carries a selected key and an unselected session key.
      # Every value bwrap needs must already be expanded into its argv or a
      # descriptor. Launch through the fake bwrap, in a scratch cwd.
      probe_launch() {
        mkdir -p "$TMPDIR/$1" "$TMPDIR/$1-home"
        (cd "$TMPDIR/$1" && env -i HOME="$TMPDIR/$1-home" LANG=C.UTF-8 \
          OPENROUTER_API_KEY=sk-fake-SENTINEL SESSION_FAKE_API_KEY=sk-fake-SESSION \
          "$2")
        test -e "$TMPDIR/$1/bwrap-environ"
        refute test -s "$TMPDIR/$1/bwrap-environ"
        refute grep -rFq -- 'sk-fake-SESSION' "$TMPDIR/$1"
        grep -Fxq -- "$TMPDIR/$1-home" "$TMPDIR/$1/bwrap-argv"
      }

      probe_launch keys ${probeKeys}/bin/jailed-pi
      grep -Fxq -- 'OPENROUTER_API_KEY' "$TMPDIR/keys/bwrap-args-21"
      grep -Fxq -- 'sk-fake-SENTINEL' "$TMPDIR/keys/bwrap-args-21"

      # Gateway: the inner launcher, past the outer's runDirectory check.
      mkdir -p "$TMPDIR/gateway-home/.config/llm-gateway/keys"
      printf 'sk-fake-GATEWAY' > "$TMPDIR/gateway-home/.config/llm-gateway/keys/pi"
      probe_gw="$(gateway_inner_of ${probeGateway}/bin/jailed-pi)"
      test -n "$probe_gw"
      probe_launch gateway "$probe_gw"
      grep -Fxq -- 'sk-fake-GATEWAY' "$TMPDIR/gateway/bwrap-args-22"
      refute grep -Fq -- 'sk-fake-SENTINEL' "$TMPDIR/gateway/bwrap-args-22"

      # The real launchers exec the same seam: every one (op-run inner and
      # gateway inner included) names an `env -i` bwrap, never bwrap bare.
      for launcher in "$spec" "$inner_path/bin/jailed-pi" "$gw_inner"; do
        seam="$(sed -n 's|^exec \(/nix/store/[^ ]*/bin/bwrap\) .*|\1|p' "$launcher")"
        test -n "$seam"
        grep -Fq -- 'env -i ${lib.getExe pkgs.bubblewrap} "$@"' "$seam"
      done

      workspace=${workspace}/bin/jailed-zsh
      grep -Fq -- "$(cat ${expectedWorkspaceBind})" "$workspace"
      grep -Fq -- '/tmp/normal /workspace/normal' "$workspace"
      eval "set -- $(cat ${expectedWorkspaceBind})"
      test "$1" = '--bind'
      test "$2" = ${lib.escapeShellArg dangerousWorkspacePath}
      test "$3" = ${lib.escapeShellArg "/workspace/quo'te$dollar;semi"}

      touch "$out"
    ''
