# satan-patcher — daemon that drains the patch_jobs postgres queue.
#
# Source: ~/dev/satan-patcher (path: input — switch to git+file:// or
# github once stable).
#
# State + artefacts:
#   ~/.config/satan-patcher/policy.toml           ← runner policy
#   ~/satan-corpus/patch-agent/prompt.md                 ← adapter system prompt
#   ~/.local/state/satan/patch-agent/{logs,worktrees}/
#
# Smoke:
#   systemctl --user status satan-patcher
#   journalctl --user -u satan-patcher -f
#   psql -d satan_memory -c '\d patch_jobs'    # 0006 must be applied
#
# jailed-pi resolved per-job via `nix build <repo>#<flake_attr>`.
# No PATH injection needed — the jail resolver shells out to nix
# directly (nix is on the service PATH via the module).
{lib, ...}: {
  name = "patcher";
  platforms = lib.platforms.linux;
  requires = ["services.postgresql"];
  homeManager = {
    inputs,
    pkgs,
    ...
  }: {
    imports = [inputs.satan-patcher.homeManagerModules.default];

    services.satan-patcher = {
      # Fenced: SL-023 PHASE-11 (DEC-063 step 1); the runner is Malebolge.
      enable = false;
      package = inputs.satan-patcher.packages.${pkgs.stdenv.hostPlatform.system}.satan-patcher;
      # The module's own default still names ~/notes/satan (CHR-003); the
      # corpus lives in its own repo since SL-015.
      systemPromptFile = "%h/satan-corpus/patch-agent/prompt.md";
    };
  };
}
