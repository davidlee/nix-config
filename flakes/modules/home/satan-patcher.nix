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
# jailed-pi is NOT bundled here; the daemon needs to find it on PATH.
# Set `services.satan-patcher.extraPathPackages` to a list containing
# whichever project's jailed-pi build should be used at daemon spawn
# time, OR set `services.satan-patcher.program` to an absolute path.
_: {
  flake.homeModules.satan-patcher = {
    inputs,
    pkgs,
    ...
  }: {
    imports = [inputs.satan-patcher.homeManagerModules.default];

    services.satan-patcher = {
      enable = true;
      package = inputs.satan-patcher.packages.${pkgs.system}.satan-patcher;
      # jailed-pi is project-specific; leave program = "jailed-pi" and
      # add the binary's package here when ready.  Until then the unit
      # will fail jobs with `adapter_failed: executable file not found`.
      extraPathPackages = [];
    };
  };
}
