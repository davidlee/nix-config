# Agents features, in projection order. Shape: README § Feature tree.
{lib, ...}: [
  {
    name = "registry";
    # Dedicated `agents` registry alias -> this flake, so ad-hoc
    # `nix shell agents#codex` (claude, gemini, opencode, pi, crush,
    # zerostack, dirge) and nix run/build resolve to self.legacyPackages —
    # a full nixpkgs with the agents overlay applied. Deliberately NOT the
    # `nixpkgs` alias: the nixpkgs-flake module routes <nixpkgs> through
    # `flake:nixpkgs`, so repointing it would make `import <nixpkgs>`
    # import this flake's dir, breaking legacy tooling.
    #
    # Explicit `to` path (not `.flake = inputs.self`): self is a subdir
    # flake (?dir=flakes), and `.flake` auto-tags the parent repo's
    # rev/narHash onto a path pointing at the subdir — the mismatch makes
    # Nix reject it ("does not contain a '/flake.nix'"). A bare path works.
    nixos = {inputs, ...}: {
      nix.registry.agents.to = {
        type = "path";
        path = inputs.self.outPath;
      };
    };
  }
  (import ./agents/gateway.nix)
  (import ./agents/quotient.nix {inherit lib;})
  {
    name = "eca";
    # ECA (editor-code-assistant) server, jailed — spawned by eca-emacs via
    # `eca-custom-command` in ~/.config/emacs/apps/dl-eca.el.
    #
    # On home.packages (not the ~/.config/emacs devshell) so Emacs finds it from any
    # buffer, independent of direnv. Emacs launches it with cwd = the workspace
    # root; `mount-cwd` binds that root at its host path too, because eca-emacs
    # hands the server absolute host paths (the jail's /workspace/<name> mount
    # alone would not resolve them). Config is read-only, cache (chat db) is
    # read-write, both from the real home rather than the jail's persisted one.
    # Emacs is in the jail so eca's shell tool can byte-compile / run ert.
    #
    # The unjailed `eca' (same pin) is installed too: dl-eca-toggle-jail.
    #
    # Gateway mode (SL-011): the jail holds no provider key, only its own
    # gateway key from ~/.config/llm-gateway/keys/eca. ~/.config/eca/config.json
    # points its provider at $LLM_GATEWAY_URL / ${env:LLM_GATEWAY_KEY}.
    #
    # Linux only: the jail is bubblewrap. Requires `agents.gateway` (the key
    # store and relay), not editor.emacs: it uses the `emacs` and `agents`
    # inputs.
    requires = ["agents.gateway"];
    platforms = lib.platforms.linux;
    homeManager = {
      inputs,
      pkgs,
      ...
    }: let
      system = pkgs.stdenv.hostPlatform.system;
      jailLib = inputs.agents.lib.${system}.mkJailedAgents {};
    in {
      home.packages = [
        jailLib.unjailed.eca
        (jailLib.makeJailedEca {
          profile = "specDev";
          extraPkgs = [inputs.emacs.packages.${system}.default];
          gateway = jailLib.gatewayClient "eca";
          extraOptions = with jailLib.combinators; [
            mount-cwd
            (try-readonly (noescape "~/.config/eca"))
            (try-readwrite (noescape "~/.cache/eca"))
          ];
        })
      ];
    };
  }
  {
    name = "pi";
    # Bare pi on PATH, outside any project devshell. Unjailed: a system-wide
    # jail would bake in a toolset, so ad-hoc confinement is a launcher
    # concern (IDE-009). From the agents pin, not home's llm-agents, so it
    # is the drv the jails bundle. Linux only: the jail library is.
    platforms = lib.platforms.linux;
    homeManager = {
      inputs,
      pkgs,
      ...
    }: {
      home.packages = [
        (inputs.agents.lib.${pkgs.stdenv.hostPlatform.system}.mkJailedAgents {}).unjailed.pi
      ];
    };
  }
  {
    name = "chatgpt";
    # pkgs.llm-agents.chatgpt builds on aarch64-darwin too: no platforms.
    homeManager = {pkgs, ...}: {
      home.packages = [pkgs.llm-agents.chatgpt];
    };
  }
]
