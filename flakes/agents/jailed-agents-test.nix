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
in
  assert knownSubagent.drvPath != "";
  assert noSecretMachinery.drvPath != "";
  assert unknownApiKeyFails;
  assert unknownSubagentFails;
  assert zeroDepthFails;
  assert relativeWorkspaceFails;
  assert duplicateWorkspaceFails;
    pkgs.runCommand "jailed-agents-policy-tests" {
      nativeBuildInputs = [pkgs.gnugrep pkgs.coreutils];
    } ''
      spec=${specDev}/bin/jailed-zsh
      research=${research}/bin/jailed-zsh
      offline=${offline}/bin/jailed-zsh

      ! grep -Fq -- '--unshare-net' "$spec"
      ! grep -Fq -- '--unshare-net' "$research"
      grep -Fq -- '--unshare-net' "$offline"
      grep -Fq -- 'home/agent' "$spec"
      grep -Fq -- 'home/agent-research' "$research"
      grep -Fq -- 'home/agent-offline' "$offline"

      grep -Fq -- 'GIT_SSH_COMMAND' "$spec"
      ! grep -Fq -- 'GIT_SSH_COMMAND' ${sshPushAllowed}/bin/jailed-zsh
      ! grep -Fq -- 'GIT_SSH_COMMAND' ${legacySshPushAllowed}/bin/jailed-zsh
      grep -Fq -- 'GIT_AUTHOR_NAME' "$spec"
      grep -Fq -- "'Jailed agent'" "$spec"
      grep -Fq -- 'jailed-agent@localhost' "$spec"
      grep -Fq -- "'Test author'" ${customIdentity}/bin/jailed-zsh
      grep -Fq -- 'committer@example.test' ${customIdentity}/bin/jailed-zsh

      # Every profile gets the guarded git, and exactly one git: the guard
      # replaces git on PATH rather than racing it for first place.
      for launcher in "$spec" "$research" "$offline"; do
        grep -q -- '--setenv PATH [^ ]*-git-guarded/bin' "$launcher"
        ! grep -q -- '--setenv PATH [^ ]*-git-[0-9][^ /]*/bin' "$launcher"
      done
      unguarded=${gitUnguarded}/bin/jailed-zsh
      ! grep -Fq -- '-git-guarded' "$unguarded"
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

      ! grep -Fq -- '/home/david' "$spec"
      ! grep -Fq -- '/run/user/1000' "$spec"

      outer=${selectedKeyOuter}/bin/jailed-pi
      grep -Fqx -- 'op=/run/wrappers/bin/op' "$outer"
      grep -Fq -- 'exec "$op" run --no-masking --env-file=' "$outer"
      env_file="$(sed -n 's/.*--env-file=\([^ ]*\).*/\1/p' "$outer")"
      test -n "$env_file"
      grep -Fqx -- 'OPENROUTER_API_KEY=op://Test/OpenRouter/credential' "$env_file"
      ! grep -Fq -- 'OPENAI_API_KEY' "$env_file"
      inner_path="$(sed -n 's|.*\(/nix/store/[^ ]*-jailed-pi\)/bin/jailed-pi.*|\1|p' "$outer")"
      test -n "$inner_path"
      ! grep -Fq -- 'OPENROUTER_API_KEY' "$inner_path/bin/jailed-pi"

      forwarded=${selectedKeyFromEnv}/bin/jailed-pi
      ! grep -Fq -- 'op run' "$forwarded"
      grep -Fq -- 'OPENROUTER_API_KEY' "$forwarded"
      ! grep -Fq -- 'OPENAI_API_KEY' "$forwarded"

      # Keys reach the jail over `--args FD`, never over bwrap's argv:
      # /proc/<pid>/cmdline is mode 444 and /proc is routinely mounted with
      # no hidepid, so an argv-borne secret is readable by every process on
      # the host for the jail's lifetime. Both forms are textually on the
      # same physical line, so assert structurally: strip every process
      # substitution, and no key name may survive into the command line.
      grep -Fq -- '--args 21 21< <(printf' "$forwarded"
      sed 's/<(printf[^)]*)//g' "$forwarded" > "$TMPDIR/argv-only"
      ! grep -Fq -- 'API_KEY' "$TMPDIR/argv-only"

      no_keys=${noKeys}/bin/jailed-pi
      ! grep -Fq -- 'op run' "$no_keys"
      ! grep -Fq -- 'API_KEY' "$no_keys"

      workspace=${workspace}/bin/jailed-zsh
      grep -Fq -- "$(cat ${expectedWorkspaceBind})" "$workspace"
      grep -Fq -- '/tmp/normal /workspace/normal' "$workspace"
      eval "set -- $(cat ${expectedWorkspaceBind})"
      test "$1" = '--bind'
      test "$2" = ${lib.escapeShellArg dangerousWorkspacePath}
      test "$3" = ${lib.escapeShellArg "/workspace/quo'te$dollar;semi"}

      touch "$out"
    ''
