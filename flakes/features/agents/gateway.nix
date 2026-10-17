# agents.gateway: the LLM gateway (design SL-011 sec-2, sec-4). LiteLLM holds
# the provider keys as the static `llm-gateway` user and serves agents on a
# unix socket; a socket-activated relay puts it on 127.0.0.1 for jails; the
# `llm-gateway` admin CLI issues per-client keys and writes the provider
# credentials. Listed in ../agents.nix. NixOS only, so no `platforms`.
{
  name = "gateway";
  nixos = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.services.llm-gateway;
    constants = import ./gateway/constants.nix;
    proxy = import ./gateway/proxy.nix {inherit pkgs lib;};
    bake = import ./gateway/bake.nix {inherit lib;};

    user = "llm-gateway"; # the service user and group, and its StateDirectory
    # The credentials are those of the providers the models use.
    providers = lib.getAttrs (lib.unique (lib.mapAttrsToList (_: m: m.provider) cfg.models)) cfg.providers;
    # The CLI writes <credstore>/<SERVICE_USER>.<provider> (baked below), with
    # the credential id (<provider>) as its --name=, which systemd checks on
    # decryption.
    credstore = "/etc/credstore.encrypted";
    credentialPath = provider: "${credstore}/${user}.${provider}";

    # A baked script, checked to parse (ast, not py_compile: no __pycache__).
    script = name: python: values:
      pkgs.writeTextFile {
        inherit name;
        executable = true;
        text = bake {
          src = ./gateway + "/${name}";
          inherit (python) interpreter;
          inherit values;
        };
        checkPhase = ''
          ${pkgs.python3.interpreter} -c 'import ast, sys; ast.parse(open(sys.argv[1]).read())' "$target"
        '';
      };

    # stdlib only; keystore.py beside it, where it imports from (and the path
    # its sudo re-exec runs: resolved, in the store).
    cli = pkgs.runCommand "llm-gateway" {} ''
      install -Dm755 ${script "llm-gateway" pkgs.python3 {
        MODELS = lib.attrNames cfg.models;
        PROVIDERS = lib.mapAttrs (_: p: p.ref) providers;
        DB = "/var/lib/${user}/keys.db";
        CREDSTORE = credstore;
        SOCKET = constants.socket;
      }} $out/libexec/llm-gateway/llm-gateway
      install -Dm644 ${./gateway/keystore.py} $out/libexec/llm-gateway/keystore.py
      mkdir $out/bin
      ln -s ../libexec/llm-gateway/llm-gateway $out/bin/llm-gateway
    '';
    serve = script "llm-gateway-serve" proxy.python {
      PROVIDERS = lib.mapAttrs (_: p: p.env) providers;
      SOCKET = constants.socket;
    };

    # Shared by the gateway and its relay. PrivateNetwork is impossible for
    # the gateway (it reaches the providers).
    hardening = {
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      PrivateDevices = true;
      NoNewPrivileges = true;
      CapabilityBoundingSet = "";
      RestrictAddressFamilies = ["AF_UNIX" "AF_INET" "AF_INET6"];
      SystemCallFilter = "@system-service";
      UMask = "0077";
    };

    strFields = fields:
      lib.types.submodule {
        options = lib.mapAttrs (_: d:
          lib.mkOption {
            type = lib.types.str;
            description = d;
          })
        fields;
      };
  in {
    options.services.llm-gateway = {
      models = lib.mkOption {
        type = lib.types.attrsOf (strFields {
          model = "LiteLLM model id";
          provider = "the provider whose key it uses (a name in `providers`)";
        });
        default = proxy.defaults.models;
        description = "Gateway model name -> LiteLLM model and provider.";
      };
      providers = lib.mkOption {
        type = lib.types.attrsOf (strFields {
          env = "the variable LiteLLM reads the key from";
          ref = "its 1Password reference (public)";
        });
        default = proxy.defaults.providers;
        description = "Provider (also its credential's name) -> key variable and op:// reference.";
      };
    };

    config = {
      assertions =
        lib.mapAttrsToList (name: m: {
          assertion = cfg.providers ? ${m.provider};
          message = "services.llm-gateway.models.${name}: provider ${m.provider} is not in services.llm-gateway.providers";
        })
        cfg.models;

      users.users.${user} = {
        isSystemUser = true;
        group = user;
      };
      users.groups.${user} = {};

      environment.systemPackages = [cli];

      systemd.services.llm-gateway = {
        description = "LLM gateway (LiteLLM) on ${constants.socket}";
        wantedBy = ["multi-user.target"];
        environment = {
          CONFIG_FILE_PATH = "${proxy.configDir {inherit (cfg) models providers;}}/config.yaml";
          LITELLM_LOCAL_MODEL_COST_MAP = "True"; # the packaged price map; no fetch at start
        };
        serviceConfig =
          hardening
          // {
            User = user;
            Group = user;
            RuntimeDirectory = constants.runtimeDirectory;
            RuntimeDirectoryMode = "0750"; # uvicorn makes the socket 0666; this gates it
            StateDirectory = user;
            StateDirectoryMode = "0700";
            LoadCredentialEncrypted = map (p: "${p}:${credentialPath p}") (lib.attrNames providers);
            ExecStart = "${serve}";
            Restart = "on-failure";
          };
      };

      # Jails reach the gateway over loopback TCP; the relay reaches the socket
      # through the group.
      systemd.sockets.llm-gateway-relay = {
        description = "LLM gateway relay on 127.0.0.1:${toString constants.relayPort}";
        wantedBy = ["sockets.target"];
        listenStreams = ["127.0.0.1:${toString constants.relayPort}"];
      };
      systemd.services.llm-gateway-relay = {
        description = "LLM gateway relay to ${constants.socket}";
        requires = ["llm-gateway.service"];
        after = ["llm-gateway.service"];
        serviceConfig =
          hardening
          // {
            ExecStart = "${config.systemd.package}/lib/systemd/systemd-socket-proxyd ${constants.socket}";
            DynamicUser = true;
            SupplementaryGroups = user;
          };
      };
    };
  };
}
