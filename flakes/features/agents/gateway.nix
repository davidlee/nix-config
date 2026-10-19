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
    username,
    ...
  }: let
    cfg = config.services.llm-gateway;
    constants = import ./gateway/constants.nix;
    proxy = import ./gateway/proxy.nix {inherit pkgs lib;};
    script = import ./gateway/bake.nix {inherit pkgs lib;};
    # Fixed by agents/gateway.nix, shared with every jail: no per-host option.
    models = proxy.defaults.models;

    user = "llm-gateway"; # the service user and group, and its StateDirectory
    # The credentials are those of the providers the models use.
    providers = lib.getAttrs (lib.unique (lib.mapAttrsToList (_: m: m.provider) models)) cfg.providers;
    # The CLI writes <credstore>/<SERVICE_USER>.<provider> (baked below), with
    # the credential id (<provider>) as its --name=, which systemd checks on
    # decryption.
    credstore = "/etc/credstore.encrypted";
    credentialPath = provider: "${credstore}/${user}.${provider}";

    # stdlib only; keystore.py beside it, where it imports from (and the path
    # its sudo re-exec runs: resolved, in the store).
    cli = pkgs.runCommand "llm-gateway" {} ''
      install -Dm755 ${script "llm-gateway" pkgs.python3 {
        MODELS = lib.attrNames models;
        PROVIDERS = lib.mapAttrs (_: p: p.ref) providers;
        DB = "/var/lib/${user}/keys.db";
        CREDSTORE = credstore;
        SOCKET = constants.socket;
      }} $out/libexec/llm-gateway/llm-gateway
      install -Dm644 ${./gateway/keystore.py} $out/libexec/llm-gateway/keystore.py
      mkdir $out/bin
      ln -s ../libexec/llm-gateway/llm-gateway $out/bin/llm-gateway
    '';
    serve = proxy.serve providers {SOCKET = constants.socket;};

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
  in {
    options.services.llm-gateway = {
      providers = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule {
          options = {
            env = lib.mkOption {
              type = lib.types.str;
              description = "the variable LiteLLM reads the key from";
            };
            ref = lib.mkOption {
              type = lib.types.str;
              description = "its 1Password reference (public)";
            };
            reportsCost = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = "the provider returns each request's billed cost and LiteLLM captures it, so its models need no price (DEC-064)";
            };
          };
        });
        default = proxy.defaults.providers;
        description = "Provider (also its credential's name) -> key variable, op:// reference and cost source.";
      };
    };

    config = {
      assertions =
        lib.mapAttrsToList (name: m: {
          assertion = cfg.providers ? ${m.provider};
          message = "agents/gateway.nix: model ${name}'s provider ${m.provider} is not in services.llm-gateway.providers";
        })
        models;

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
          CONFIG_FILE_PATH = "${proxy.configDir {
            inherit models;
            inherit (cfg) providers;
          }}/config.yaml";
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

      # Jails reach the gateway over loopback TCP, or (isolated-netns jails) the
      # user-owned client socket; the relay reaches the gateway socket through
      # the group.
      systemd.sockets.llm-gateway-relay = {
        description = "LLM gateway relay on 127.0.0.1:${toString constants.relayPort}";
        wantedBy = ["sockets.target"];
        listenStreams = ["127.0.0.1:${toString constants.relayPort}" constants.clientSocket];
        socketConfig = {
          SocketUser = username;
          SocketMode = "0600";
          DirectoryMode = "0755";
        };
      };
      systemd.services.llm-gateway-relay = {
        description = "LLM gateway relay to ${constants.socket}";
        requires = ["llm-gateway.service"];
        after = ["llm-gateway.service"];
        # switch-to-configuration ignores a changed .socket unit (NixOS#74899);
        # a changed service makes it stop service and socket, then start the socket.
        restartTriggers = [config.systemd.units."llm-gateway-relay.socket".unit];
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
