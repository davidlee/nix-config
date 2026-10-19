# satan-runner — SATAN's patch-job runner (malebolge; SL-023 design §5.2-§5.3).
# Owns patch jobs end to end: one job at a time per repo, run by pi in the
# oubliette room `assistant`, reached through the room's host-local door, its
# models through the LLM gateway. Serves the control socket Emacs submits to.
# Each submit names a mode, SATAN's acting lane, whose repos and allowed_paths
# scope it; a submit outside them is refused (SL-025 DEC-069).
#
# Source: the malebolge input's packages.runner (bin/satan-runner: nodejs_24 on
# its src/runner-main.ts, production deps only), pinned by flake.lock (CHR-017).
#
# Runs as the user (a user unit): the oubliette module owner, the only uid that
# reads the room's 0700 /var/lib/capsule/room/assistant/ (CON-003, SL-023 EX-5).
#
# Files:
#   ~/.config/satan-runner/config.toml       ← rendered below; read once at start
#   ~/.config/satan-runner/ssh_config        ← the door's ProxyCommand
#   ~/.config/malebolge/gateway-models.json  ← the same catalog render, for the interactive
#                                              daemon (not this unit); a stable path, since
#                                              the store path moves on every rebuild
#   ~/.local/state/satan/runner/runner.sqlite ← jobs, job_events, pi-durable
#   $XDG_RUNTIME_DIR/satan-runner/control.sock ← bound into no jail (I4)
#   gateway key: LoadCredential=, never argv or environment (DEC-049)
#
# Smoke (runbook: ~/flakes/SATAN.md § satan-runner):
#   systemctl --user status satan-runner
#   journalctl --user -u satan-runner -f
#   cd ~/dev/malebolge && SATAN_RUNNER_LIVE=1 just smoke-runner
{lib, ...}: {
  name = "runner";
  platforms = lib.platforms.linux;
  homeManager = {
    inputs,
    pkgs,
    config,
    ...
  }: let
    home = config.home.homeDirectory;
    runner = inputs.malebolge.packages.${pkgs.stdenv.hostPlatform.system}.runner;
    configDir = "${home}/.config/satan-runner";

    gatewayData = import ../../agents/gateway.nix;
    piGatewayConfig = import ../../agents/pi-gateway.nix {inherit lib;};
    # The jails' own render of the gateway's pi catalog (SL-023 EX-8): one
    # function, one data file, never copied.
    catalog =
      pkgs.writeText "satan-runner-gateway.json"
      (builtins.toJSON (piGatewayConfig gatewayData.url gatewayData.models));

    # The room's door and the repos it holds. Literals: the fleet
    # (/srv/fleet/flake.nix rooms.assistant, targets/<repo>.nix) exposes no
    # room data to home-manager, so these copy it by hand (SL-023 PHASE-12
    # E4; one source is IMP-044).
    room = "assistant";
    roomUser = "agent"; # rooms.assistant.repos.user
    socket = "/run/capsule-room/${room}/ssh.sock";

    # One repo per room target, keyed by the oubliette target name (SL-025
    # design §4.3): `path` is targets/<name>.nix `path`, `defaultBranch` the
    # host checkout's integration branch.
    roomRepo = path: defaultBranch: name: {
      inherit path;
      guest_path = "/work/${name}"; # the target's guestPath
      default_branch = defaultBranch;
      quarantine = "/var/lib/capsule/collect/${room}/${name}.git";
      transfer_timeout_s = 600; # covers a first full push
    };
    repo = lib.mapAttrs (name: f: f name) {
      doctrine = roomRepo "${home}/dev/doctrine" "edge";
      goad-walk = roomRepo "${home}/dev/goad-walk" "main";
      goad = roomRepo "${home}/dev/goad" "main";
      satan-attrd = roomRepo "${home}/dev/satan-attrd" "main";
      panopticon = roomRepo "${home}/dev/panopticon" "main";
      malebolge = roomRepo "${home}/dev/malebolge" "main";
      retrograde = roomRepo "${home}/dev/retrograde" "main";
      oubliette = roomRepo "${home}/dev/oubliette" "main";
      www = roomRepo "${home}/dev/www" "main";
      resume = roomRepo "${home}/dev/resume" "main";
      notes = roomRepo "${home}/notes" "main";
      emacs-config = roomRepo "${home}/.config/emacs" "main";
      nix-config = roomRepo home "main";
      satan = roomRepo "${home}/dev/satan" "main";
      satan-corpus = roomRepo "${home}/satan-corpus" "main";
    };

    # The runner's config, held once (design §5.3); every table is closed, so a
    # misspelt key refuses start (I13). Values are never derived by the runner.
    settings = {
      # The runner's kill switch (authority ledger row 6), apart from the unit.
      # Shipped parked: a home switch starts the unit (I14). Enable: SATAN.md.
      enabled = true;
      # Explicit, no fallback: must exist before start, even parked (CHR-003).
      prompt_file = "${home}/satan-corpus/prompts/patch-agent.md";
      # Absolute; a job may only lower these. cost_usd: first deploy, cheap model.
      maxima = {
        model_requests = 200;
        cost_usd = 0.50;
        tokens = 2000000;
        active_wall_clock_s = 3600;
        soft_threshold = 0.8;
        max_room_wait_s = 21600;
        max_pending_collection_s = 86400;
      };
      defaults.model = "gateway/deepseek-flash";
      # SATAN's lanes; Emacs stamps the acting one on each submit (DEC-068).
      # Each mode's scope is required and checked at submit (DEC-069); none
      # sets a model or ceiling, so all fall through to defaults and maxima.
      mode = {
        self-edit-mech = {
          repos = ["satan"];
          allowed_paths = ["satan/"];
        };
        self-edit-mind = {
          repos = ["satan-corpus"];
          allowed_paths = ["prompts/" "system/" "tools/"];
        };
        # Computed here so a new room repo joins it; the runner gets a literal.
        tick-agent = {
          repos = lib.subtractLists ["satan" "satan-corpus"] (lib.attrNames repo);
          allowed_paths = "*";
        };
        # The human's own lane and the smoke's (RSK-019).
        interactive = {
          repos = "*";
          allowed_paths = "*";
        };
      };
      inherit repo;
      door = {
        kind = "room";
        inherit room;
        user = roomUser;
        # The runner's own key; its public half is in rooms.assistant.users.agent.keys (CON-004).
        identity = "${home}/.ssh/malebolge.key";
        # oubliette's, learnt by its push (accept-new); the runner only reads it.
        known_hosts = "/var/lib/capsule/room/${room}/known_hosts";
        host_key_alias = "room-${room}";
        session_path = "/run/current-system/sw/bin/session"; # the guest's
        ssh_config = "${configDir}/ssh_config";
      };
      gateway = {
        catalog = "${catalog}";
        # A file name in $CREDENTIALS_DIRECTORY: the LoadCredential= id below.
        credential = "satan-runner";
      };
    };
  in {
    xdg.configFile = {
      # The interactive daemon (`node src/daemon-main.ts`, not this unit) reads
      # the runner's own catalog render, never a copy; see SATAN.md.
      "malebolge/gateway-models.json".source = catalog;
      "satan-runner/config.toml".source =
        (pkgs.formats.toml {}).generate "satan-runner-config.toml" settings;
      # pi-env fixes ServerAliveInterval=15 on its command line and passes
      # HostKeyAlias, StrictHostKeyChecking and UserKnownHostsFile itself;
      # only the count is ours: 3 × 15 s, a backstop to pi-env's 30 s silence
      # limit (design §5.2 Execution environment).
      "satan-runner/ssh_config".text = ''
        Host *
          ProxyCommand ${pkgs.socat}/bin/socat - UNIX-CONNECT:${socket}
          ServerAliveCountMax 3
      '';
    };

    systemd.user.services.satan-runner = {
      Unit = {
        Description = "SATAN patch-job runner (malebolge)";
        Documentation = "file:${home}/flakes/SATAN.md";
        # Nothing on the room: a down room is routine (oubliette DEC-031).
        # A refused start (exit 1) must not spin.
        StartLimitIntervalSec = 300;
        StartLimitBurst = 5;
      };
      Service = {
        ExecStart = "${runner}/bin/satan-runner";
        Environment = [
          "SATAN_RUNNER_CONFIG=${configDir}/config.toml"
          # StateDirectory's root for a user unit (%S) when the manager sets no
          # XDG_STATE_HOME; explicit so the runner's store and it agree (I13).
          "XDG_STATE_HOME=${home}/.local/state"
          # capsule (the room's verbs); the rest for git, ssh and the relay.
          "PATH=/run/current-system/sw/bin:${lib.makeBinPath [pkgs.git pkgs.openssh pkgs.socat pkgs.coreutils]}"
        ];
        # The gateway key: in $CREDENTIALS_DIRECTORY only (EX-8). Absolute:
        # the key file is the gateway client's, named for it (agents/gateway.nix).
        LoadCredential = "${settings.gateway.credential}:${home}/.config/llm-gateway/keys/satan-runner";
        # $XDG_RUNTIME_DIR/satan-runner/; the runner makes the socket 0600.
        RuntimeDirectory = "satan-runner";
        RuntimeDirectoryMode = "0700";
        # ~/.local/state/satan/runner/ (%S = ~/.local/state for a user unit).
        StateDirectory = "satan/runner";
        StateDirectoryMode = "0700";
        Restart = "on-failure";
        RestartSec = 10;
      };
      Install.WantedBy = ["default.target"];
    };
  };
}
