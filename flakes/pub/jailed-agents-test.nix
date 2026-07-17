{
  pkgs,
  jail-nix,
}: let
  inherit (pkgs) lib;
  system = pkgs.stdenv.system;

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

      ! grep -Fq -- '/home/david' "$spec"
      ! grep -Fq -- '/run/user/1000' "$spec"

      outer=${selectedKeyOuter}/bin/jailed-pi
      grep -Fq -- 'exec op run --no-masking --env-file=' "$outer"
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
