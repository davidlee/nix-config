# satan-patcher — daemon that drains the patch_jobs postgres queue.
#
# Source: ~/dev/satan-patcher (path: input — switch to git+file:// or
# github once stable).
#
# State + artefacts:
#   ~/.config/satan-patcher/policy.toml           ← runner policy
#   ~/notes/satan/patch-agent/prompt.md           ← adapter system prompt
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
{
  inputs,
  pkgs,
  ...
}: {
  imports = [inputs.satan-patcher.homeManagerModules.default];

  services.satan-patcher = {
    enable = true;
    package = inputs.satan-patcher.packages.${pkgs.system}.satan-patcher;
    opBin = "/run/wrappers/bin/op";
    opAccount = "my.1password.com";
    apiKeyRefs = {
      OPENROUTER_API_KEY = "op://API_KEYS/OPENROUTER_API_KEY/credential";
      DEEPSEEK_API_KEY = "op://API_KEYS/DEEPSEEK_API_KEY/credential";
    };
  };
}
