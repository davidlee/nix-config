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
      eca = fakeAgent "eca";
    };
  };
  mkAgents = extra:
    import ./jailed-agents.nix (
      {
        inherit pkgs jail-nix;
        llm-agents = fakeAgents;
        zmx = fakeAgent "zmx";
        zmx-new = fakeAgent "zmx-new";
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

  inner = profile: args:
    agents.makeJailedZsh (
      {
        inherit profile;
      }
      // args
    );
  specDev = inner "specDev" {};
  research = inner "research" {};
  offline = inner "offline" {};
  # specDev without the launch-dir bind: starts in $HOME (DEC-078)
  launchDirOff = inner "specDev" {mountLaunchDir = false;};
  # specDev with the launch dir read-only (malebolge:DEC-074 (4))
  launchDirRo = inner "specDev" {readOnlyLaunchDir = true;};
  # A named persisted home replaces the profile's, whatever its network (satan:SL-027 RV-035 F-6)
  homeSpec = inner "specDev" {persistedHome = "probe-home";};
  homeResearch = inner "research" {persistedHome = "probe-home";};
  homeOffline = inner "offline" {persistedHome = "probe-home";};
  sshPushAllowed = inner "specDev" {blockSshGitPush = false;};
  gitUnguarded = inner "specDev" {guardGit = false;};
  noHostDoctrine = inner "specDev" {hostDoctrine = false;};
  # A Nix-built doctrine whose closure holds a path no jail otherwise has.
  nixDoctrineMarker = pkgs.writeText "nix-doctrine-closure-marker" "";
  fakeNixDoctrine = pkgs.writeShellScriptBin "doctrine" ": ${nixDoctrineMarker}";
  withNixDoctrine = inner "specDev" {nixDoctrine = fakeNixDoctrine;};
  customIdentity = customIdentityAgents.makeJailedZsh {
    profile = "specDev";
  };
  knownSubagent = agents.makeJailedAgent {
    name = "custom";
    agent = fakeAgent "custom";
    subagents = ["pi"];
    maxSubagentDepth = 2;
  };
  dangerousWorkspacePath = "/tmp/work dep/quo'te$dollar;semi";
  workspace = inner "specDev" {
    workspaceDeps = ["/tmp/normal/" dangerousWorkspacePath];
  };
  # workspaceDeps bind read-only, workspaceDepsRw read-write (DEC-081)
  workspaceRw = inner "specDev" {
    workspaceDepsRw = ["/tmp/normal-rw/" dangerousWorkspacePath];
  };
  expectedWorkspaceBindAs = flag:
    pkgs.writeText "expected-workspace-bind${flag}" (
      builtins.replaceStrings ["$"] ["'\"$\"'"] (
        lib.escapeShellArgs [
          flag
          dangerousWorkspacePath
          "/workspace/quo'te$dollar;semi"
        ]
      )
    );
  expectedWorkspaceBind = expectedWorkspaceBindAs "--ro-bind";
  expectedWorkspaceRwBind = expectedWorkspaceBindAs "--bind";

  # Real bwrap needs user namespaces, which the build sandbox lacks. This
  # stand-in, under bwrap's own name and store slot, records what bwrap
  # would start with: its initial environ (/proc/$$/environ, as bwrap's
  # /proc/1/environ reads inside the jail), its argv, and the `--args`
  # descriptors. No PATH: it must work from an empty environment.
  fakeBwrap = pkgs.writeShellScriptBin "bwrap" ''
    tr=${pkgs.coreutils}/bin/tr
    "$tr" '\0' '\n' < /proc/$$/environ > bwrap-environ
    printf '%s\n' "$@" > bwrap-argv
    for fd in 22; do
      if [ -e /dev/fd/$fd ]; then "$tr" '\0' '\n' < /dev/fd/$fd > bwrap-args-$fd; fi
    done
  '';
  fakeBwrapAgents = mkAgents {
    pkgs = pkgs.extend (_: _: {bubblewrap = fakeBwrap;});
  };
  probeGateway = fakeBwrapAgents.makeJailedPi {gateway = gw;};
  # pi's models.json bind (bind, or twin without it, differing only in):
  # probeGateway / piNoGateway                     the gateway
  # piResearchGateway / customResearchGateway      the agent, not its name
  # claudePiGateway / claudeGateway                pi as a subagent
  # probeGateway / ecaGateway                      pi in the jail at all
  piNoGateway = agents.makeJailedPi {};
  piResearchGateway = fakeBwrapAgents.makeJailedPi {
    name = "pi-research";
    profile = "research";
    gateway = gw;
  };
  customResearchGateway = fakeBwrapAgents.makeJailedAgent {
    name = "pi-research";
    agent = fakeAgent "custom";
    profile = "research";
    gateway = gw;
  };
  claudePiGateway = fakeBwrapAgents.makeJailedClaude {
    gateway = gw;
    subagents = ["pi"];
  };
  claudeGateway = fakeBwrapAgents.makeJailedClaude {gateway = gw;};
  # A caller's own node (a project's toolchain) against the library's.
  callerNode = pkgs.writeShellScriptBin "node" "exit 0";
  piCallerNode = agents.makeJailedPi {extraPkgs = [callerNode];};
  ecaGateway = fakeBwrapAgents.makeJailedEca {gateway = gw;};

  # gatewayForwarder's behaviour, without namespaces: this bwrap drops its
  # options (everything up to `--`) and execs the entry, so the real launcher
  # runs the real wrap-entry wrapper on the build sandbox's own loopback.
  passBwrap = pkgs.writeShellScriptBin "bwrap" ''
    while [ "$#" -gt 0 ] && [ "$1" != -- ]; do shift; done
    shift
    exec "$@"
  '';
  passJail = jail-nix.lib.extend {
    inherit pkgs;
    bubblewrapPackage = passBwrap;
  };
  gatewayForwarder = import ./gateway-forwarder.nix {
    inherit pkgs;
    inherit (passJail) combinators;
  };
  forwarderSocket = "/tmp/jailed-agents-forwarder/api.sock";
  # The probe jail's entry: argv reaches it through the launcher's and the
  # wrapper's "$@".
  #   relay PORT LOG  no upstream connection yet; a request round-trips;
  #                   then exactly one upstream connection (LOG's lines)
  #   ran MARKER      the entry ran
  #   exit N          the entry's exit status
  forwarderClient = pkgs.writeShellApplication {
    name = "forwarder-client";
    runtimeInputs = [pkgs.socat pkgs.coreutils];
    text = ''
      fail() {
        echo "forwarder-client: $*" >&2
        exit 1
      }
      case "$1" in
        relay)
          port="$2" log="$3"
          [ ! -e "$log" ] || fail "the upstream was reached before the entry ran"
          reply="$(printf 'ping\n' | socat -t 5 - "TCP:127.0.0.1:$port")"
          [ "$reply" = "pong ping" ] || fail "reply: '$reply'"
          [ "$(wc -l < "$log")" = 1 ] || fail "upstream connections: $(wc -l < "$log")"
          ;;
        ran) touch "$2" ;;
        exit) exit "$2" ;;
        *) fail "unknown mode: $1" ;;
      esac
    '';
  };
  forwarderProbe = port:
    passJail "forwarder-probe-${toString port}" forwarderClient
    (gatewayForwarder {
      socket = forwarderSocket;
      inherit port;
    });
  forwarderUpstream = pkgs.writeShellScript "forwarder-upstream" ''
    echo accepted >> "$FORWARDER_LOG"
    read -r line
    printf 'pong %s\n' "$line"
  '';

  failsToEvaluate = value: !(builtins.tryEval value.drvPath).success;
  unknownSubagentFails = failsToEvaluate (agents.makeJailedAgent {
    name = "custom";
    agent = fakeAgent "custom";
    subagents = ["not-an-agent"];
  });
  zeroDepthFails = failsToEvaluate (agents.makeJailedAgent {
    name = "custom";
    agent = fakeAgent "custom";
    subagents = ["pi"];
    maxSubagentDepth = 0;
  });
  relativeWorkspaceFails = failsToEvaluate (inner "specDev" {
    workspaceDeps = ["relative/path"];
  });
  duplicateWorkspaceFails = failsToEvaluate (inner "specDev" {
    workspaceDeps = ["/tmp/one/shared" "/tmp/two/shared"];
  });
  relativeRwWorkspaceFails = failsToEvaluate (inner "specDev" {
    workspaceDepsRw = ["relative/path"];
  });
  # One destination, whatever the modes: the lists are guarded as a union.
  crossListDuplicateFails = failsToEvaluate (inner "specDev" {
    workspaceDeps = ["/tmp/one/shared"];
    workspaceDepsRw = ["/tmp/one/shared"];
  });
  # persistedHome is spliced unescaped into a path and shell: the twin is
  # homeOffline, differing only in the name.
  badHomeFails = failsToEvaluate (inner "offline" {persistedHome = "../escape";});
  # The maker adds the prefix: "jailed-pi-x" would build jailed-jailed-pi-x.
  # Twin: knownSubagent, a custom name without it.
  prefixedNameFails = failsToEvaluate (agents.makeJailedPi {name = "jailed-pi-x";});

  gatewayData = import ./gateway.nix;

  # Gateway mode. runDirectory cannot exist in the build sandbox, so the
  # outer wrapper's checks are observable without reaching bwrap.
  gw = {
    keyFile = "$HOME/.config/llm-gateway/keys/pi";
    url = "http://127.0.0.1:4000/v1";
    runDirectory = "/nonexistent/llm-gateway";
  };
  gatewayJail = agents.makeJailedPi {gateway = gw;};
  # Each refusal's twin is gatewayJail, differing only in the shape.
  gatewayMissingKeyFileFails = failsToEvaluate (agents.makeJailedPi {
    gateway = builtins.removeAttrs gw ["keyFile"];
  });
  gatewayUnknownAttrFails = failsToEvaluate (agents.makeJailedPi {
    gateway = gw // {socket = "/nonexistent/llm-gateway/api.sock";};
  });

  # Socket mode (DEC-076): a gateway jail whose profile has no network.
  offlineGateway = agents.makeJailedPi {
    profile = "offline";
    gateway = gw;
  };
  # gatewaySocketOptions without `gateway` (key-file clients, e.g. jailed-malebolge).
  offlineSocketOptions = inner "offline" {extraOptions = agents.gatewaySocketOptions;};
  # The netns guard, each paired with a twin: offlineGateway (no network
  # option), offlineSocketOptions (the profile).
  socketModeNetworkFails = failsToEvaluate (agents.makeJailedPi {
    profile = "offline";
    gateway = gw;
    extraOptions = [agents.combinators.network];
  });
  gatewaySocketOptionsNetworkedFails = failsToEvaluate (inner "specDev" {
    extraOptions = agents.gatewaySocketOptions;
  });
  # A satan-mcp client (DEC-088): the socket's directory, read-only.
  satanMcp = inner "specDev" {extraOptions = agents.satanMcpOptions;};
  audio = inner "specDev" {extraOptions = agents.audioOptions agents.combinators;};

  # pi's gateway provider. A served model without a pi block is left out
  # (DEC-066). One fixture holds both, differing only in the pi block, so the
  # omission cannot pass vacuously. toJSON forces the model list: a bare
  # tryEval stops at weak head normal form and would pass whatever it holds.
  noPi = {
    model = "m";
    provider = "p";
  };
  withPi = noPi // {pi.name = "X";};
  piConfigOf = models: builtins.toJSON (agents.piGatewayConfig gw.url models);
  noPiEntryOmitted =
    (builtins.tryEval (piConfigOf {
      x = noPi;
      y = withPi;
    })).success;
  # The bound file for gateway.nix's served models: those with a pi block.
  expectedPiModels = pkgs.writeText "expected-pi-gateway-models.json" (builtins.toJSON {
    providers.llm-gateway = {
      baseUrl = gw.url;
      api = "openai-completions";
      apiKey = "$LLM_GATEWAY_KEY";
      models = lib.mapAttrsToList (id: m: {inherit id;} // m.pi) (lib.filterAttrs (_: m: m ? pi) gatewayData.models);
    };
  });
  mixedPiConfig = agents.piGatewayConfig gw.url {
    x = noPi;
    y = withPi;
  };

  # The posture over plain jail.nix combinators, as quotient's builder
  # passes them (IMP-052), in a jail of its own.
  plainJail = jail-nix.lib.extend {inherit pkgs;};
  postureProbe = args: plainJail "posture-probe" pkgs.hello (agents.posture args plainJail.combinators);
  postureFull = postureProbe {sandboxGitIdentity = true;};
  postureBare = postureProbe {
    sandboxGitIdentity = false;
    hostDoctrine = false;
    blockSshGitPush = false;
    guardGit = false;
  };

  # quotient's builder, stubbed to return what it was called with (IMP-046).
  stubQuotient.lib.mkFormFamily = args: args;
  formArgs = agents.quotientFormFamily {
    quotient = stubQuotient;
    options = c: [
      (c.set-env "PROJECT_OPTION" "x")
      (c.add-runtime "RUNTIME_ARGS+=(--setenv CALLER_RUNTIME_OPTION x)")
    ];
    prefix = "proj";
    packages = [pkgs.hello];
    env.EXTRA = "x";
    piFiles."settings.json" = pkgs.writeText "settings.json" "{}";
  };
  # A form's options are the posture, then the caller's (IMP-052).
  formProbe = args: plainJail "form-probe" pkgs.hello (args.options plainJail.combinators);
  formFull = formProbe formArgs;
  formNoDoctrine = formProbe (agents.quotientFormFamily {
    quotient = stubQuotient;
    postureFlags.hostDoctrine = false;
  });
  formNixDoctrine = formProbe (agents.quotientFormFamily {
    quotient = stubQuotient;
    postureFlags.nixDoctrine = fakeNixDoctrine;
  });
  # A form-safe env forward, over plain combinators as a form passes them.
  fwdProbe = plainJail "fwd-probe" pkgs.hello [(agents.tryFwdEnv plainJail.combinators "PROJECT_VAR")];
  fwdBadNameFails = !(builtins.tryEval (agents.tryFwdEnv plainJail.combinators "1-bad")).success;
  piClient = agents.gatewayClient "pi";
  # The expression a form's launcher assigns, for the test to run.
  formKeyExpr = pkgs.writeText "form-key-expr" formArgs.secretEnv.LLM_GATEWAY_KEY;
  quotientInJail = import ./quotient-in-jail.nix {
    inherit lib pkgs;
    inherit (plainJail) combinators;
  };
  inherit (quotientInJail) etcStoreBinds;
  formNetworkOffFails =
    !(builtins.tryEval (agents.quotientFormFamily {
      quotient = stubQuotient;
      network = false;
    } ? pi)).success;
  # IMP-051: models are reached through the gateway only. No argument
  # resolves or forwards a provider key.
  noProviderKeyArgs =
    lib.all (a: !(builtins.functionArgs agents.makeJailedAgent ? ${a})) ["apiKeys" "useOpEnv" "passApiKeysFromEnv"]
    && !(builtins.functionArgs (import ./jailed-agents.nix) ? apiKeyOpRefs);

  # quotientServer: a fake server and form family, each with a marker in its
  # closure, so the jail's closure binds can be read for them.
  fakeQuotientPart = name: bin: let
    marker = pkgs.writeText "${name}-closure-marker" "";
  in {
    inherit marker;
    pkg = pkgs.writeShellScriptBin bin ": ${marker}";
  };
  qServer = fakeQuotientPart "quotient-server" "quotient";
  qRead = fakeQuotientPart "quotient-read" "quotient-read";
  qWrite = fakeQuotientPart "quotient-write" "quotient-write";
  qs = {
    package = qServer.pkg;
    forms = {
      read = qRead.pkg;
      write = qWrite.pkg;
    };
  };
  # Every field of the policy the jail carries, written out (DEC-123).
  expectedPolicy = {
    schema = "quotient-policy/2";
    mode = "per-call";
    enabled = true;
    roots = ["/workspace"];
    maxima = {
      requests = 60;
      context_tokens = 280000;
      cost_usd = 1.0;
      wall_clock_s = 900;
    };
    profiles = {
      read = "read";
      research = "read";
      review = "read";
      judgement = "read";
      write = "write";
      implement = "write";
    };
    forms = {
      read = "${qRead.pkg}/bin/quotient-read";
      write = "${qWrite.pkg}/bin/quotient-write";
    };
    exposure = [];
    transcript_budget_bytes = 4096;
  };
  policyMatches = quotientInJail.policy qs.forms == expectedPolicy;
  qsClaude = fakeBwrapAgents.makeJailedClaude {
    gateway = gw;
    quotientServer = qs;
  };
  qsCodex = fakeBwrapAgents.makeJailedCodex {
    gateway = gw;
    quotientServer = qs;
  };
  # Jails that declare it and register nothing, each with its twin without it.
  qsShell = fakeBwrapAgents.makeJailedAgent {
    name = "shell";
    agent = fakeAgent "shell";
    gateway = gw;
    quotientServer = qs;
  };
  plainShell = fakeBwrapAgents.makeJailedAgent {
    name = "shell";
    agent = fakeAgent "shell";
    gateway = gw;
  };
  qsZsh = fakeBwrapAgents.makeJailedZsh {
    gateway = gw;
    quotientServer = qs;
  };
  plainZsh = fakeBwrapAgents.makeJailedZsh {gateway = gw;};
  qsPi = fakeBwrapAgents.makeJailedPi {
    gateway = gw;
    quotientServer = qs;
  };
  plainClaude = fakeBwrapAgents.makeJailedClaude {gateway = gw;};
  plainCodex = fakeBwrapAgents.makeJailedCodex {gateway = gw;};
  # Refused with the relay, which is exclusive, without a gateway, and offline.
  # Each twin differs in that one property alone, and evaluates: qsClaude, a
  # relay jail, and an offline gateway jail.
  qsWithRelayFails = failsToEvaluate (agents.makeJailedClaude {
    gateway = gw;
    quotient = true;
    quotientServer = qs;
  });
  relayAlone = agents.makeJailedClaude {
    gateway = gw;
    quotient = true;
  };
  qsNoGatewayFails = failsToEvaluate (agents.makeJailedClaude {quotientServer = qs;});
  qsOfflineFails = failsToEvaluate (agents.makeJailedClaude {
    profile = "offline";
    gateway = gw;
    quotientServer = qs;
  });
  offlineGatewayClaude = agents.makeJailedClaude {
    profile = "offline";
    gateway = gw;
  };
  # null is off: the same jail as one that never heard of it.
  qsNullSame =
    (fakeBwrapAgents.makeJailedClaude {
      gateway = gw;
      quotientServer = null;
    }).drvPath
    == plainClaude.drvPath;

  # The jail scan (IMP-051). Every test jail, outer and nested launchers.
  scannedJails = [
    specDev
    research
    offline
    knownSubagent
    gatewayJail
    offlineGateway
    ecaGateway
    claudePiGateway
    piResearchGateway
    qsClaude
    qsCodex
    qsShell
    qsZsh
    qsPi
  ];
  opUnjailedClean = agents.opUnjailed scannedJails;
  # Twin: specDev, differing only in the ancestor bind.
  runBound = inner "specDev" {extraOptions = [(agents.combinators.ro-bind "/run" "/run")];};
  opUnjailedCatches = pkgs.testers.testBuildFailure (agents.opUnjailed [runBound]);
  customScan = agents.mkJailScanCheck {
    name = "probe-scan";
    launchers = scannedJails;
    literals = ["satan-runner"];
    tokens = ["/run/user/[0-9]+/?"];
    controlBind = "--bind /run/user/1000 /run/user/1000";
  };
in
  assert noProviderKeyArgs;
  assert knownSubagent.drvPath != "";
  assert fwdBadNameFails;
  assert unknownSubagentFails;
  assert zeroDepthFails;
  assert relativeWorkspaceFails;
  assert duplicateWorkspaceFails;
  assert relativeRwWorkspaceFails;
  assert crossListDuplicateFails;
  assert homeOffline.drvPath != "";
  assert badHomeFails;
  assert prefixedNameFails;
  assert gatewayMissingKeyFileFails;
  assert gatewayUnknownAttrFails;
  assert offlineGateway.drvPath != "";
  assert offlineSocketOptions.drvPath != "";
  assert socketModeNetworkFails;
  assert gatewaySocketOptionsNetworkedFails;
  assert satanMcp.drvPath != "";
  assert qsClaude.drvPath != "" && relayAlone.drvPath != "" && offlineGatewayClaude.drvPath != "";
  assert qsWithRelayFails;
  assert qsNoGatewayFails;
  assert qsOfflineFails;
  assert policyMatches;
  assert qsNullSame;
  assert agents.gatewayClient "pi"
  == {
    keyFile = "$HOME/.config/llm-gateway/keys/pi";
    inherit (gatewayData) url;
    runDirectory = "/run/llm-gateway";
  };
  # A form family carries the gateway wiring and the caller's own args.
  assert formArgs.pi == agents.unjailed.pi;
  assert formArgs.prefix == "proj";
  assert formArgs.packages == [pkgs.hello];
  assert formArgs.env
  == {
    EXTRA = "x";
    LLM_GATEWAY_URL = piClient.url;
  };
  assert formArgs.secretEnv == {LLM_GATEWAY_KEY = ''''${LLM_GATEWAY_KEY:-$(< "${piClient.keyFile}")}'';};
  assert lib.attrNames formArgs.piFiles == ["models.json" "settings.json"];
  assert formArgs.piFiles."models.json" == agents.piGatewayModels;
  assert formNetworkOffFails;
  assert noPiEntryOmitted;
  # The gateway facts out-of-tree consumers read instead of gateway.nix (IMP-043).
  assert lib.attrNames agents.gatewayFacts == ["clientSocket" "models" "relayPort" "url"];
  assert agents.gatewayFacts.clientSocket == gatewayData.clientSocket;
  # The host's env list, resolved for this pkgs; the library applies none of it.
  assert agents.hostDevEnv == (import ./dev-env.nix).for pkgs;
  # The host's sccache socket never reaches a jail through the env list a
  # consumer applies there (SL-023 PHASE-07 F-1).
  assert !(agents.hostDevEnv.env ? SCCACHE_SERVER_UDS);
  assert mixedPiConfig
  == {
    providers.llm-gateway = {
      baseUrl = gw.url;
      api = "openai-completions";
      apiKey = "$LLM_GATEWAY_KEY";
      models = [
        {
          id = "y";
          name = "X";
        }
      ];
    };
  };
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

      # The inner launcher a gateway wrapper execs: gateway_inner_of <outer> <name>.
      gateway_inner_of() {
        sed -n "s|^exec \(/nix/store/[^ ]*-jailed-$2/bin/jailed-$2\) .*|\1|p" "$1"
      }

      # Gateway mode, as text: gateway_probes <outer> <inner>. No op wrapper
      # and no provider key; the gateway key reaches the jail over its own
      # `--args FD`, read by a shell builtin.
      gateway_probes() {
        test -n "$2"
        refute grep -Fq -- 'op run' "$1"
        refute grep -Fq -- '/run/wrappers/bin/op' "$1"
        grep -Fq -- '--args 22 22< <(printf' "$2"
        grep -Fq -- '--setenv LLM_GATEWAY_KEY "$(<' "$2"
        refute grep -Fq -- 'cat ' "$2"
        refute grep -Fq -- 'API_KEY' "$2"
        refute grep -Fq -- '--args 21' "$2"
        grep -Fq -- '--setenv LLM_GATEWAY_URL ${lib.escapeShellArg gw.url}' "$2"
        # Argv safety, as for provider keys. The strip stops at the first `)`,
        # which closes the nested `$(<` — after the key's name.
        sed 's/<(printf[^)]*)//g' "$2" > "$TMPDIR/gw-argv-only"
        refute grep -Fq -- 'LLM_GATEWAY_KEY' "$TMPDIR/gw-argv-only"
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

      # persistedHome (F-6): replaces each profile's home; network is the profile's.
      for launcher in ${homeSpec}/bin/jailed-zsh ${homeResearch}/bin/jailed-zsh ${homeOffline}/bin/jailed-zsh; do
        grep -Fq -- 'home/probe-home ~' "$launcher"
        refute grep -Fq -- 'home/agent' "$launcher"
      done
      refute grep -Fq -- '--unshare-net' ${homeSpec}/bin/jailed-zsh
      refute grep -Fq -- '--unshare-net' ${homeResearch}/bin/jailed-zsh
      grep -Fq -- '--unshare-net' ${homeOffline}/bin/jailed-zsh

      grep -Fq -- 'GIT_SSH_COMMAND' "$spec"
      refute grep -Fq -- 'GIT_SSH_COMMAND' ${sshPushAllowed}/bin/jailed-zsh
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

      # Host excludes: mounted read-only at git's default excludes path, as a
      # runtime arg, so after (on top of) the persisted home bind and off the
      # bwrap line (quotient's form check refuses `$(` there, IMP-052).
      for launcher in "$spec" "$research" "$offline"; do
        grep -q -- 'RUNTIME_ARGS+=(--ro-bind-try "$([^)]*-host-git-excludes-file)" "$HOME/.config/git/ignore")' "$launcher"
        refute grep -Fq -- ' ~/.config/git/ignore' "$launcher"
        home_at="$(grep -bo -- '--bind ~/.local/share/jail.nix/home/[^ ]* ~' "$launcher" | cut -d: -f1)"
        runtime_at="$(grep -boF -- '"''${RUNTIME_ARGS[@]}"' "$launcher" | cut -d: -f1)"
        test -n "$home_at"
        test -n "$runtime_at"
        test "$runtime_at" -gt "$home_at"
      done

      # Host doctrine: the directory of its own install root, read-only, at
      # its own host path and on PATH (DEC-110). A directory, never the file:
      # a file bind pins one inode, and `cargo install` renames a new file
      # over it (IMP-249). A runtime arg, so after the persisted home bind
      # over ~. Absent on the host, the jail still launches: the bind is a try.
      host_doctrine='"$HOME/.local/share/doctrine/bin"'
      # The jail's PATH value alone: the bwrap call is one line.
      jail_path() { grep -o -- '--setenv PATH [^ ]*' "$1"; }
      # A path is in the jail's closure: closure_has <launcher> <path>. Not
      # grep -q: under pipefail, its early exit fails tr with SIGPIPE at random.
      closure_has() {
        f="$(grep -o '/nix/store/[^ ]*-runtime-closure-bind-args' "$1" | head -1)"
        test -n "$f"
        tr '\0' '\n' < "$f" | grep -Fx -- "$2" > /dev/null
      }
      for launcher in "$spec" "$research" "$offline"; do
        grep -Fq -- "RUNTIME_ARGS+=(--ro-bind-try $host_doctrine $host_doctrine)" "$launcher"
        jail_path "$launcher" | grep -Fq -- "$host_doctrine"
        refute grep -Fq -- '/bin/doctrine ' "$launcher"
        # No doctrine mount under /run: not the old one, nor a Nix build's.
        refute grep -Fq -- '/run/doctrine' "$launcher"
        # Closure binds as runtime args, not a descriptor on the bwrap line.
        grep -Fq -- "-elf-closure-binds $host_doctrine/doctrine)" "$launcher"
        grep -Fq -- 'RUNTIME_ARGS+=("''${doctrine_binds[@]}")' "$launcher"
        refute grep -Fq -- '--args 23' "$launcher"
      done
      refute grep -Fq -- 'doctrine' ${noHostDoctrine}/bin/jailed-zsh

      # The library holds the host env list but applies none of it.
      refute grep -Fq -- 'RUSTC_WRAPPER' "$spec"

      # A Nix-built doctrine: its bin/ at /run/doctrine-nix-bin, read-only,
      # never on PATH (DEC-109); its closure is bound, so it runs there.
      nix_doctrine=${withNixDoctrine}/bin/jailed-zsh
      grep -Fq -- '--ro-bind ${fakeNixDoctrine}/bin /run/doctrine-nix-bin' "$nix_doctrine"
      jail_path "$nix_doctrine" > "$TMPDIR/nix-doctrine-path"
      refute grep -Fq -- 'doctrine-nix-bin' "$TMPDIR/nix-doctrine-path"
      refute grep -Fq -- '${fakeNixDoctrine}' "$TMPDIR/nix-doctrine-path"
      closure_has "$nix_doctrine" '${nixDoctrineMarker}'

      # Behaviour: the closure binds name what a dynamic ELF links against,
      # and nothing for a missing file or a script.
      binds="$(grep -o '/nix/store/[^ )]*-elf-closure-binds' "$spec" | head -1)"
      test -n "$binds"
      closure="$("$binds" ${pkgs.hello}/bin/hello | tr '\0' ' ')"
      glibc=${lib.getLib pkgs.stdenv.cc.libc}
      [[ $closure == *"--ro-bind-try $glibc $glibc"* ]]
      refute grep -Fq -- '${pkgs.hello}' <<<"$closure"
      test -z "$("$binds" "$TMPDIR/absent")"
      test -z "$("$binds" ${pkgs.writeShellScript "not-elf" ""})"

      # Behaviour: the resolver mirrors git's own lookup.
      resolver="$(grep -o '/nix/store/[^ )]*-host-git-excludes-file' "$spec" | head -1)"
      fake="$TMPDIR/fake-home"
      mkdir -p "$fake"
      test "$(env -i HOME="$fake" "$resolver")" = "$fake/.config/git/ignore"
      test "$(env -i HOME="$fake" XDG_CONFIG_HOME="$fake/xdg" "$resolver")" = "$fake/xdg/git/ignore"
      printf '[core]\n  excludesFile = ~/.gitignore_global\n' > "$fake/.gitconfig"
      test "$(env -i HOME="$fake" "$resolver")" = "$fake/.gitignore_global"

      # The posture alone, over plain combinators: every part, and each
      # flag removes its own.
      full=${postureFull}/bin/posture-probe
      bare=${postureBare}/bin/posture-probe
      for marker in -git-guarded/bin "$host_doctrine" -host-git-excludes-file \
        GIT_SSH_COMMAND GIT_AUTHOR_NAME CLAUDE_CODE_SHELL /usr/bin/env; do
        grep -Fq -- "$marker" "$full"
      done
      # sccache's server runs the compiler: every jail keeps its own on a
      # socket in its private /tmp, never the host's (SL-023 PHASE-07 F-1).
      for probe in "$full" "$bare"; do
        grep -Fq -- '--setenv SCCACHE_SERVER_UDS /tmp/sccache.sock' "$probe"
      done
      for marker in -git-guarded doctrine GIT_SSH_COMMAND GIT_AUTHOR_NAME; do
        refute grep -Fq -- "$marker" "$bare"
      done
      grep -Fq -- '${pkgs.git}/bin' "$bare"
      grep -Fq -- '-host-git-excludes-file' "$bare"
      # Terminal settings are the launcher's: a quotient form is headless and
      # sets TERM=dumb itself.
      refute grep -Fq -- 'xterm-256color' "$full"
      grep -Fq -- 'xterm-256color' "$spec"

      # A form: the posture with sandboxed git identity on, then the
      # caller's options; a posture flag reaches it.
      form=${formFull}/bin/form-probe
      for marker in -git-guarded/bin "$host_doctrine" GIT_AUTHOR_NAME PROJECT_OPTION; do
        grep -Fq -- "$marker" "$form"
      done
      refute grep -Fq -- 'doctrine' ${formNoDoctrine}/bin/form-probe
      grep -Fq -- '--ro-bind ${fakeNixDoctrine}/bin /run/doctrine-nix-bin' ${formNixDoctrine}/bin/form-probe

      # A form's store binds (DEC-125) come after the caller's options, as
      # runtime args, and only where there is no store database: on the host
      # the network combinator has already bound them.
      caller_at="$(grep -bo -- 'CALLER_RUNTIME_OPTION x' "$form" | cut -d: -f1)"
      guard_at="$(grep -bo -- 'if \[ ! -e /nix/var/nix/db \]; then' "$form" | cut -d: -f1)"
      binds_at="$(grep -bo -- '-etc-store-binds /etc/hosts /etc/nsswitch.conf /etc/resolv.conf /etc/ssl)' "$form" | cut -d: -f1)"
      test -n "$caller_at"
      test -n "$guard_at"
      test -n "$binds_at"
      test "$caller_at" -lt "$guard_at"
      test "$guard_at" -lt "$binds_at"
      grep -Fq -- 'RUNTIME_ARGS+=("''${etc_binds[@]}")' "$form"
      grep -- '/bin/bwrap ' "$form" > "$TMPDIR/form-bwrap-line"
      refute grep -Fq -- 'etc-store-binds' "$TMPDIR/form-bwrap-line"

      # Behaviour: a form's key (DEC-124). The environment wins, as in a jail,
      # which has no key file; the file serves where the variable is unset or
      # empty, as on the host; with neither, nothing is invented.
      form_key() { # form_key <HOME> [VAR=value]
        (export HOME="$1"; shift; [ "$#" = 0 ] || export "$@"; eval "printf %s $(cat ${formKeyExpr})" 2> /dev/null)
      }
      key_home="$TMPDIR/form-key-home"
      mkdir -p "$key_home/.config/llm-gateway/keys"
      test "$(form_key "$TMPDIR/no-such-home" LLM_GATEWAY_KEY=sk-from-env)" = sk-from-env
      printf 'sk-from-file' > "$key_home/.config/llm-gateway/keys/pi"
      test "$(form_key "$key_home" LLM_GATEWAY_KEY=sk-from-env)" = sk-from-env
      test "$(form_key "$key_home")" = sk-from-file
      test "$(form_key "$key_home" LLM_GATEWAY_KEY=)" = sk-from-file
      test -z "$(form_key "$TMPDIR/no-such-home")"

      # Behaviour: etc-store-binds names each store path the links resolve to,
      # once, as NUL-separated bwrap words, and nothing else: no regular file,
      # no link out of the store, no missing argument.
      etc="$TMPDIR/etc-fixture"
      mkdir -p "$etc/ssl/certs"
      ln -s ${pkgs.hello}/bin/hello "$etc/hosts"
      ln -s "$etc/hosts" "$etc/nsswitch.conf"
      ln -s ${pkgs.hello}/share "$etc/ssl/certs/same-path"
      ln -s ${pkgs.jq}/bin/jq "$etc/ssl/certs/other-path"
      ln -s "$TMPDIR" "$etc/ssl/out-of-store"
      ln -s "$TMPDIR/absent" "$etc/ssl/dangling"
      echo plain > "$etc/resolv.conf"
      ${etcStoreBinds} "$etc/hosts" "$etc/nsswitch.conf" "$etc/resolv.conf" "$etc/ssl" "$etc/absent" > "$TMPDIR/etc-binds"
      {
        for p in $(printf '%s\n' ${pkgs.hello} ${lib.getBin pkgs.jq} | sort); do
          printf '%s\0' --ro-bind-try "$p" "$p"
        done
      } | cmp - "$TMPDIR/etc-binds"
      ${etcStoreBinds} "$etc/resolv.conf" "$etc/absent" > "$TMPDIR/etc-binds-none"
      refute test -s "$TMPDIR/etc-binds-none"

      # tryFwdEnv forwards at launch through RUNTIME_ARGS, so the bwrap line
      # stays plain words for quotient's check; unset, nothing is added.
      fwd=${fwdProbe}/bin/fwd-probe
      grep -Fq -- 'RUNTIME_ARGS+=(--setenv PROJECT_VAR "$PROJECT_VAR")' "$fwd"
      grep -- '/bin/bwrap ' "$fwd" > "$TMPDIR/fwd-bwrap-line"
      refute grep -Fq -- 'PROJECT_VAR' "$TMPDIR/fwd-bwrap-line"

      refute grep -Fq -- '/home/david' "$spec"
      for launcher in "$spec" "$research" "$offline"; do
        refute grep -Fq -- '/run/user/1000' "$launcher"
      done

      # No provider key and no `op run` without a gateway either (IMP-051).
      default_keys=${piNoGateway}/bin/jailed-pi
      refute grep -Fq -- 'op run' "$default_keys"
      refute grep -Fq -- 'API_KEY' "$default_keys"

      # Gateway mode (see gateway_probes).
      gw_outer=${gatewayJail}/bin/jailed-pi
      gw_inner="$(gateway_inner_of "$gw_outer" pi)"
      gateway_probes "$gw_outer" "$gw_inner"

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

      # Socket mode (offlineGateway): no network, the client socket's
      # directory bound read-only, and the entry is the forwarder wrapper,
      # relaying the gateway's port to llm-gateway-client's socket.
      og_outer=${offlineGateway}/bin/jailed-pi
      og_inner="$(gateway_inner_of "$og_outer" pi)"
      gateway_probes "$og_outer" "$og_inner"
      grep -Fq -- '--ro-bind /run/llm-gateway-client /run/llm-gateway-client' "$og_inner"
      grep -Fq -- '--unshare-net' "$og_inner"
      refute grep -Fq -- '--share-net' "$og_inner"
      wrapper="$(grep -o -- '-- /nix/store/[^ ]*-jailed-pi-jail-wrapper/bin/jailed-pi-jail-wrapper' "$og_inner" | cut -c4-)"
      test -n "$wrapper"
      grep -Fq -- 'TCP-LISTEN:${toString gatewayData.relayPort},bind=127.0.0.1' "$wrapper"
      grep -Fq -- 'UNIX-CONNECT:/run/llm-gateway-client/api.sock' "$wrapper"
      # Its pre-flight checks the client socket's directory, not runDirectory.
      grep -Fq -- '/run/llm-gateway-client' "$og_outer"
      refute grep -Fq -- '${gw.runDirectory}' "$og_outer"
      grep -Fq -- '${gw.runDirectory}' "$gw_outer"
      if "$og_outer" 2> "$TMPDIR/og-no-gateway"; then exit 1; fi
      grep -Fq -- '/run/llm-gateway-client' "$TMPDIR/og-no-gateway"
      grep -Fq -- 'just system-switch' "$TMPDIR/og-no-gateway"
      grep -Fq -- 'systemctl status llm-gateway' "$TMPDIR/og-no-gateway"
      grep -Fq -- 'just gateway-credentials' "$TMPDIR/og-no-gateway"
      # gatewaySocketOptions alone (offlineSocketOptions): the inner launcher
      # itself, so the bind and the forwarder entry, and no pre-flight.
      so=${offlineSocketOptions}/bin/jailed-zsh
      grep -Fq -- '--ro-bind /run/llm-gateway-client /run/llm-gateway-client' "$so"
      grep -q -- '-- /nix/store/[^ ]*-jailed-zsh-jail-wrapper/bin/jailed-zsh-jail-wrapper' "$so"
      # satanMcpOptions: the directory read-only, never the socket file (it
      # pins the inode satan-mcp-start replaces, ISS-042) and never writable
      # (the jail could replace the socket and impersonate satan-mcp).
      sm=${satanMcp}/bin/jailed-zsh
      grep -Fq -- '--ro-bind-try /run/user/1000/satan/mcp /run/user/1000/satan/mcp ' "$sm"
      grep -Fq -- 'SATAN_MCP_SOCKET' "$sm"
      grep -Fq -- 'XDG_RUNTIME_DIR' "$sm"
      refute grep -Fq -- 'mcp/mcp.sock' "$sm"
      refute grep -Eq -- '--bind(-try)? /run/user/1000/satan/mcp' "$sm"
      # audioOptions: the host's pulse directory at a path of the jail's own, and
      # never XDG_RUNTIME_DIR: a jail cannot write the host's, and tools take it
      # for their own.
      au=${audio}/bin/jailed-zsh
      grep -Fq -- '--bind-try "''${XDG_RUNTIME_DIR:-}/pulse" /run/host-pulse' "$au"
      grep -Fq -- '--setenv PULSE_SERVER unix:/run/host-pulse/native' "$au"
      grep -Fq -- 'voice_hang_up.wav' "$au"
      refute grep -Fq -- 'XDG_RUNTIME_DIR "$XDG_RUNTIME_DIR"' "$au"
      # A gateway jail with network is unchanged: no client socket, no wrapper.
      for launcher in "$gw_inner" "$gw_outer"; do
        refute grep -Fq -- 'llm-gateway-client' "$launcher"
      done
      refute grep -Fq -- 'jail-wrapper' "$gw_inner"

      # Behaviour: the emitted read expands keyFile at run time and yields
      # the key intact, as one NUL-separated --setenv.
      read_key="$(grep -o "printf '%s\\\\0' --setenv LLM_GATEWAY_KEY \"\$(< \"[^\"]*\")\"" "$gw_inner")"
      test -n "$read_key"
      eval "$read_key" > "$TMPDIR/gw-args"
      printf '%s\0' --setenv LLM_GATEWAY_KEY sk-test-SENTINEL | cmp -s - "$TMPDIR/gw-args"

      # Behaviour: bwrap starts with an EMPTY environment. --clearenv empties
      # only the child's; bwrap's own environ is what it was exec'd with, and
      # bwrap is PID 1 in the jail, where /proc/1/environ is readable. The
      # launch env carries a provider key and a session key; neither may
      # reach bwrap.
      # Every value bwrap needs must already be expanded into its argv or a
      # descriptor. Launch through the fake bwrap, in a scratch cwd.
      probe_launch() {
        mkdir -p "$TMPDIR/$1" "$TMPDIR/$1-home"
        (cd "$TMPDIR/$1" && env -i HOME="$TMPDIR/$1-home" LANG=C.UTF-8 \
          OPENROUTER_API_KEY=sk-fake-SENTINEL SESSION_FAKE_API_KEY=sk-fake-SESSION \
          "$2" "''${@:3}")
        test -e "$TMPDIR/$1/bwrap-environ"
        refute test -s "$TMPDIR/$1/bwrap-environ"
        refute grep -rFq -- 'sk-fake-SESSION' "$TMPDIR/$1"
        refute grep -rFq -- 'sk-fake-SENTINEL' "$TMPDIR/$1"
        grep -Fxq -- "$TMPDIR/$1-home" "$TMPDIR/$1/bwrap-argv"
      }

      # Gateway: the inner launcher, past the outer's runDirectory check,
      # with gw's key staged (keys/pi, whichever the jail). fd 22 carries
      # that key and no provider key: gateway_launch <label> <inner> [ARG...].
      gateway_launch() {
        mkdir -p "$TMPDIR/$1-home/.config/llm-gateway/keys"
        printf 'sk-fake-GATEWAY' > "$TMPDIR/$1-home/.config/llm-gateway/keys/pi"
        test -n "$2"
        probe_launch "$@"
        grep -Fxq -- 'sk-fake-GATEWAY' "$TMPDIR/$1/bwrap-args-22"
      }
      probe_gw="$(gateway_inner_of ${probeGateway}/bin/jailed-pi pi)"
      gateway_launch gateway "$probe_gw"

      # The real launchers exec the same seam: every one (gateway inner
      # included) names an `env -i` bwrap, never bwrap bare.
      for launcher in "$spec" "$gw_inner"; do
        seam="$(sed -n 's|^exec \(/nix/store/[^ ]*/bin/bwrap\) .*|\1|p' "$launcher")"
        test -n "$seam"
        grep -Fq -- 'env -i ${lib.getExe pkgs.bubblewrap} "$@"' "$seam"
      done

      # pi in gateway mode: a store models.json bound read-only over the
      # persisted home's, so after its bind, wherever pi is in the jail (the
      # agent under any name, or a subagent), and nowhere else.
      research_inner="$(gateway_inner_of ${piResearchGateway}/bin/jailed-pi-research pi-research)"
      claude_pi_inner="$(gateway_inner_of ${claudePiGateway}/bin/jailed-claude claude)"
      models_bind='--ro-bind /nix/store/[^ ]*-pi-gateway-models.json ~/.pi/agent/models.json'
      bound=""
      for i in "$probe_gw" "$research_inner" "$claude_pi_inner"; do
        test -n "$i"
        test "$(grep -o -- "$models_bind" "$i" | wc -l)" = 1
        home_at="$(grep -bo -- '--bind ~/.local/share/jail.nix/home/[^ ]* ~' "$i" | cut -d: -f1)"
        models_at="$(grep -bo -- "$models_bind" "$i" | cut -d: -f1)"
        test -n "$home_at"
        test -n "$models_at"
        test "$models_at" -gt "$home_at"
        # Same url and models, so the same store file for every jail.
        this="$(grep -o -- "$models_bind" "$i")"
        test -z "$bound" || test "$this" = "$bound"
        bound="$this"
      done

      # The new gateway jails pass the same no-key probes.
      eca_outer=${ecaGateway}/bin/jailed-eca
      eca_inner="$(gateway_inner_of "$eca_outer" eca)"
      gateway_probes ${piResearchGateway}/bin/jailed-pi-research "$research_inner"
      gateway_probes ${claudePiGateway}/bin/jailed-claude "$claude_pi_inner"
      gateway_probes "$eca_outer" "$eca_inner"
      gateway_launch research "$research_inner"
      gateway_launch claude-pi "$claude_pi_inner"
      gateway_launch eca "$eca_inner"

      # I4 (SL-023 REQ-016): the satan-runner control socket is bound into no
      # jail. Every launcher built above, outer and inner.
      for launcher in "$spec" "$research" "$offline" \
        "$gw_outer" "$gw_inner" "$research_inner" "$claude_pi_inner" \
        "$eca_outer" "$eca_inner"; do
        test -f "$launcher" # a missing file would make the refute vacuous
        refute grep -Fq -- 'satan-runner' "$launcher"
      done
      # Launched, bwrap gets the bind's target under the launching HOME.
      for label in gateway research claude-pi; do
        grep -Fxq -- "$TMPDIR/$label-home/.pi/agent/models.json" "$TMPDIR/$label/bwrap-argv"
      done
      refute grep -Fq -- 'models.json' "$TMPDIR/eca/bwrap-argv"

      # The malebolge bridge (malebolge:DEC-074), wherever pi is and nowhere
      # else: the bridge directory read-only, never its parent (which holds
      # durable.sock), and pi-bridge/ read-only as pi's extension, both after
      # the persisted-home bind. The sandbox has no /run/user, so the host-side
      # mkdir fails there and the launch still goes ahead (-try skips it).
      bridge_dir=/run/user/1000/satan/durable/room/bridge
      for label in gateway research claude-pi; do
        argv="$TMPDIR/$label/bwrap-argv"
        home_at="$(grep -nFx -- "$TMPDIR/$label-home" "$argv" | head -1 | cut -d: -f1)"
        dir_at="$(grep -nFx -- "$bridge_dir" "$argv" | head -1 | cut -d: -f1)"
        ext_at="$(grep -nFx -- "$TMPDIR/$label-home/.pi/agent/extensions/malebolge-bridge" "$argv" | cut -d: -f1)"
        test -n "$home_at"
        test -n "$dir_at"
        test -n "$ext_at"
        test "$(sed -n "$((dir_at - 1))p" "$argv")" = --ro-bind-try
        test "$(sed -n "$((dir_at + 1))p" "$argv")" = "$bridge_dir"
        test "$(sed -n "$((ext_at - 2))p" "$argv")" = --ro-bind-try
        test "$(sed -n "$((ext_at - 1))p" "$argv")" = "$TMPDIR/$label-home/dev/malebolge/pi-bridge"
        test "$dir_at" -gt "$home_at"
        test "$ext_at" -gt "$home_at"
        refute grep -Eq -- '^/run/user/1000/satan/durable(/room)?/?$' "$argv"
      done
      for i in "$probe_gw" "$research_inner" "$claude_pi_inner"; do
        grep -Fq -- "(umask 077 && mkdir -p $bridge_dir)" "$i"
        grep -Fq -- 'RUNTIME_ARGS+=(--setenv MALEBOLGE_BRIDGE_SOCKET "$MALEBOLGE_BRIDGE_SOCKET")' "$i"
        grep -Fq -- 'RUNTIME_ARGS+=(--setenv XDG_RUNTIME_DIR "$XDG_RUNTIME_DIR")' "$i"
      done
      for i in "$TMPDIR/eca/bwrap-argv" "$eca_inner" "$spec"; do
        test -f "$i" # a missing file would make the refute vacuous
        refute grep -Fq -- 'malebolge' "$i"
        refute grep -Fq -- 'satan/durable' "$i"
      done

      # node on PATH wherever pi is (malebolge-bridge, malebolge:DEC-075),
      # and only there.
      node_path='--setenv PATH [^ ]*-nodejs-24[^ /]*/bin'
      for i in "$probe_gw" "$research_inner" "$claude_pi_inner"; do
        grep -q -- "$node_path" "$i"
      done
      for i in "$eca_inner" "$(gateway_inner_of ${claudeGateway}/bin/jailed-claude claude)"; do
        test -f "$i" # a missing file would make the refute vacuous
        refute grep -q -- "$node_path" "$i"
      done
      # The caller's packages precede the library's node: a project's own
      # node wins in the jail (SL-023 PHASE-05 F-2).
      path_of() { grep -o -- '--setenv PATH [^ ]*' "$1" | cut -d' ' -f3 | tr : '\n'; }
      caller_at="$(path_of ${piCallerNode}/bin/jailed-pi | grep -nF -- '${callerNode}/bin' | cut -d: -f1)"
      lib_at="$(path_of ${piCallerNode}/bin/jailed-pi | grep -n -- '-nodejs-24[^/]*/bin$' | cut -d: -f1)"
      [ -n "$caller_at" ] && [ -n "$lib_at" ] && [ "$caller_at" -lt "$lib_at" ] || {
        echo "FAIL caller node (PATH entry ''${caller_at:-none}) must precede the library's (''${lib_at:-none})" >&2
        exit 1
      }

      for i in \
        "$eca_inner" \
        "$(gateway_inner_of ${customResearchGateway}/bin/jailed-pi-research pi-research)" \
        "$(gateway_inner_of ${claudeGateway}/bin/jailed-claude claude)" \
        "$default_keys"; do
        test -f "$i" # a missing file would make the refute vacuous
        refute grep -Fq -- 'models.json' "$i"
      done
      models_file="$(grep -o '/nix/store/[^ ]*-pi-gateway-models.json' "$probe_gw" | head -1)"
      test -n "$models_file"
      cmp "$models_file" ${expectedPiModels}
      # the lib's export (IMP-043) is the file a gateway jail binds
      test "$models_file" = ${agents.piGatewayModels}
      grep -Fq -- '"apiKey":"$LLM_GATEWAY_KEY"' "$models_file"

      workspace=${workspace}/bin/jailed-zsh
      grep -Fq -- "$(cat ${expectedWorkspaceBind})" "$workspace"
      grep -Fq -- '--ro-bind /tmp/normal /workspace/normal' "$workspace"
      eval "set -- $(cat ${expectedWorkspaceBind})"
      test "$1" = '--ro-bind'
      test "$2" = ${lib.escapeShellArg dangerousWorkspacePath}
      test "$3" = ${lib.escapeShellArg "/workspace/quo'te$dollar;semi"}

      workspace_rw=${workspaceRw}/bin/jailed-zsh
      grep -Fq -- "$(cat ${expectedWorkspaceRwBind})" "$workspace_rw"
      grep -Fq -- '--bind /tmp/normal-rw /workspace/normal-rw' "$workspace_rw"
      eval "set -- $(cat ${expectedWorkspaceRwBind})"
      test "$1" = '--bind'
      test "$2" = ${lib.escapeShellArg dangerousWorkspacePath}
      test "$3" = ${lib.escapeShellArg "/workspace/quo'te$dollar;semi"}

      # The launch dir binds after every workspace dep, so the project is the
      # one visible when a dep shares its basename (DEC-082).
      # The bwrap call is one line, so compare byte offsets, not line numbers.
      dep_at="$(grep -boF -- '/workspace/normal' "$workspace" | head -1 | cut -d: -f1)"
      launch_at="$(grep -boF -- '--bind "$PWD"' "$workspace" | head -1 | cut -d: -f1)"
      test -n "$dep_at"
      test -n "$launch_at"
      test "$dep_at" -lt "$launch_at"

      # mountLaunchDir: on (default) binds the cwd and starts in it; off binds
      # nothing and starts in $HOME. --chdir is passed either way, or bwrap
      # reads HOME from its own environment.
      launch_off=${launchDirOff}/bin/jailed-zsh
      grep -Fq -- '/workspace/$(basename' "$spec"
      grep -Fq -- '--chdir "/workspace/$(basename' "$spec"
      refute grep -Fq -- '/workspace/$(basename' "$launch_off"
      grep -Fq -- '--chdir "$HOME"' "$launch_off"
      grep -Fq -- '--chdir' "$launch_off"
      # readOnlyLaunchDir: the same mount and start, bound read-only.
      launch_ro=${launchDirRo}/bin/jailed-zsh
      grep -Fq -- '--ro-bind "$PWD" "/workspace/$(basename' "$launch_ro"
      grep -Fq -- '--chdir "/workspace/$(basename' "$launch_ro"
      refute grep -Fq -- '--bind "$PWD"' "$launch_ro"
      refute grep -Fq -- '--ro-bind "$PWD"' "$spec"

      # gatewayForwarder: real socat, passthrough bwrap (see passBwrap). Every
      # launch and wait is bounded, and no launch is captured by $(…): the
      # forwarder outlives the entry and holds the launch's descriptors.
      socat=${pkgs.socat}/bin/socat
      fwd_fail() {
        echo "gatewayForwarder: $*" >&2
        cat "$TMPDIR"/fwd-*.err >&2 || true
        exit 1
      }
      fwd_wait() { # about 30 s
        for _ in $(seq 600); do
          if eval "$1"; then return 0; fi
          sleep 0.05
        done
        fwd_fail "timed out waiting for: $1"
      }
      mkdir -p /tmp/jailed-agents-forwarder "$TMPDIR/fwd-home"
      export HOME="$TMPDIR/fwd-home" LANG=C.UTF-8 TERM=dumb # what the launcher forwards

      # (c) No upstream at all: readiness needs none, and the entry's exit
      # status is the launch's.
      status=0
      timeout 30 ${forwarderProbe 4002}/bin/forwarder-probe-4002 exit 7 \
        < /dev/null > "$TMPDIR/fwd-c.out" 2> "$TMPDIR/fwd-c.err" || status=$?
      [ "$status" = 7 ] || fwd_fail "(c) exit status $status, expected 7"

      # (b) The port is already bound by another process: the launch fails
      # before the entry runs, even though that process's row is in LISTEN.
      "$socat" TCP-LISTEN:4001,bind=127.0.0.1,fork EXEC:true \
        < /dev/null > "$TMPDIR/fwd-occupier.out" 2> "$TMPDIR/fwd-occupier.log" &
      fwd_wait "grep -q ' 0100007F:0FA1 00000000:0000 0A ' /proc/net/tcp"
      if timeout 30 ${forwarderProbe 4001}/bin/forwarder-probe-4001 ran "$TMPDIR/fwd-b.ran" \
        < /dev/null > "$TMPDIR/fwd-b.out" 2> "$TMPDIR/fwd-b.err"; then
        fwd_fail "(b) launched on an occupied port"
      fi
      grep -Fq -- 'forwarder exited' "$TMPDIR/fwd-b.err" || fwd_fail "(b) no 'forwarder exited'"
      refute test -e "$TMPDIR/fwd-b.ran"

      # (a) Request and reply pass through. The UNIX-LISTEN upstream logs each
      # connection: none during readiness, one for the client's request.
      export FORWARDER_LOG="$TMPDIR/fwd-a.log"
      "$socat" UNIX-LISTEN:${forwarderSocket},fork EXEC:${forwarderUpstream} \
        < /dev/null > "$TMPDIR/fwd-upstream.out" 2> "$TMPDIR/fwd-upstream.log" &
      fwd_wait "[ -S ${forwarderSocket} ]"
      timeout 30 ${forwarderProbe 4000}/bin/forwarder-probe-4000 relay 4000 "$FORWARDER_LOG" \
        < /dev/null > "$TMPDIR/fwd-a.out" 2> "$TMPDIR/fwd-a.err" || fwd_fail "(a) relay failed"

      # quotientServer: the real quotient in the jail (quotient-in-jail.nix).
      # What a launch hands bwrap, one word per line of bwrap-argv.
      # argv_bind_line <label> <flag> <source regex> <destination>: the line
      # of the first FLAG whose two words match, or nothing.
      argv_bind_line() {
        awk -v f="$2" -v s="$3" -v d="$4" \
          '$0 == f { n = NR; getline a; getline b; if (a ~ s && b == d) { print n; exit } }' \
          "$TMPDIR/$1/bwrap-argv"
      }
      # The entry and its words: everything after bwrap's own options.
      entry_words() { sed -n '/^--$/,$p' "$TMPDIR/$1/bwrap-argv" | tail -n +2; }

      qs_claude="$(gateway_inner_of ${qsClaude}/bin/jailed-claude claude)"
      qs_codex="$(gateway_inner_of ${qsCodex}/bin/jailed-codex codex)"
      plain_claude="$(gateway_inner_of ${plainClaude}/bin/jailed-claude claude)"
      gateway_launch qs-claude "$qs_claude" "two words" plain
      gateway_launch qs-codex "$qs_codex" "two words" plain
      gateway_launch plain-claude "$plain_claude" "two words" plain
      gateway_launch plain-codex "$(gateway_inner_of ${plainCodex}/bin/jailed-codex codex)" "two words" plain

      # The config lands on top of the persisted home, the host's profiles on
      # top of the config; each bind is a flag and both of its words.
      qdir="$TMPDIR/qs-claude-home/.config/quotient"
      home_line="$(argv_bind_line qs-claude --bind "^$TMPDIR/qs-claude-home/.local/share/jail.nix/home/" "$TMPDIR/qs-claude-home")"
      config_line="$(argv_bind_line qs-claude --ro-bind '^/nix/store/[^ ]*-quotient-jail-config$' "$qdir")"
      profiles_line="$(argv_bind_line qs-claude --ro-bind-try "^$qdir/profiles$" "$qdir/profiles")"
      test -n "$home_line"
      test -n "$config_line"
      test -n "$profiles_line"
      test "$config_line" -gt "$home_line"
      test "$profiles_line" -gt "$config_line"
      # The config: the policy, and an empty mount point for the profiles.
      config_dir="$(sed -n "$((config_line + 1))p" "$TMPDIR/qs-claude/bwrap-argv")"
      test "$(ls -A "$config_dir" | tr '\n' ' ')" = "policy.json profiles "
      test -d "$config_dir/profiles"
      test -z "$(ls -A "$config_dir/profiles")"
      cmp "$config_dir/policy.json" ${pkgs.writeText "expected-policy.json" (builtins.toJSON expectedPolicy)}

      # The server and both forms are in the closure, and on PATH.
      for pair in ${qServer.marker}:${qServer.pkg} ${qRead.marker}:${qRead.pkg} ${qWrite.marker}:${qWrite.pkg}; do
        closure_has "$qs_claude" "''${pair%%:*}"
        closure_has "$qs_codex" "''${pair%%:*}"
        jail_path "$qs_claude" | grep -Fq -- "''${pair##*:}/bin"
      done

      # Registration: the agent's own entry, then the server's words, then
      # the caller's, each one word.
      mcp_file="$(sed -n 's|^--mcp-config=||p' "$TMPDIR/qs-claude/bwrap-argv")"
      test -n "$mcp_file"
      closure_has "$qs_claude" "$mcp_file" # the jail sees only its closure
      printf '%s' '{"mcpServers":{"quotient":{"command":"${qServer.pkg}/bin/quotient"}}}' | cmp -s - "$mcp_file"
      entry_words plain-claude > "$TMPDIR/plain-claude.words"
      entry="$(head -1 "$TMPDIR/plain-claude.words")"
      test -n "$entry"
      printf '%s\n' "$entry" "--mcp-config=$mcp_file" "two words" plain > "$TMPDIR/qs-claude.want"
      entry_words qs-claude | cmp - "$TMPDIR/qs-claude.want"
      printf '%s\n' "$entry" "two words" plain | cmp - "$TMPDIR/plain-claude.words"
      codex_entry="$(entry_words plain-codex | head -1)"
      test -n "$codex_entry"
      printf '%s\n' "$codex_entry" -c 'mcp_servers.quotient.command="${qServer.pkg}/bin/quotient"' \
        -c 'mcp_servers.quotient.env_vars=["LLM_GATEWAY_KEY","LLM_GATEWAY_URL"]' "two words" plain \
        > "$TMPDIR/qs-codex.want"
      entry_words qs-codex | cmp - "$TMPDIR/qs-codex.want"

      # A jail that declares it but is not claude or codex: the config is
      # there, the entry's words are the caller's alone.
      for pair in shell:${qsShell}/bin/jailed-shell:${plainShell}/bin/jailed-shell \
        zsh:${qsZsh}/bin/jailed-zsh:${plainZsh}/bin/jailed-zsh \
        pi:${qsPi}/bin/jailed-pi:${probeGateway}/bin/jailed-pi; do
        IFS=: read -r who with_outer without_outer <<<"$pair"
        gateway_launch "qs-$who" "$(gateway_inner_of "$with_outer" "$who")" "two words" plain
        gateway_launch "plain-$who" "$(gateway_inner_of "$without_outer" "$who")" "two words" plain
        test -n "$(argv_bind_line "qs-$who" --ro-bind '^/nix/store/[^ ]*-quotient-jail-config$' "$TMPDIR/qs-$who-home/.config/quotient")"
        entry_words "qs-$who" | cmp - <(entry_words "plain-$who")
        refute grep -Fq -- '.config/quotient' "$TMPDIR/plain-$who/bwrap-argv"
      done
      # Declared nothing: no config, no quotient in the closure.
      refute grep -Fq -- '.config/quotient' "$TMPDIR/plain-claude/bwrap-argv"
      if closure_has "$plain_claude" ${qServer.marker}; then exit 1; fi
      refute grep -Fq -- 'quotient' "$plain_claude"

      # The jail scan: clean over every test jail; an ancestor bind fails it.
      grep -Fq -- 'op-unjailed: ' ${opUnjailedClean}
      grep -Fq -- "has the argument '/run'" ${opUnjailedCatches}/testBuildFailure.log
      grep -Fq -- 'probe-scan: ' ${customScan}

      touch "$out"
    ''
