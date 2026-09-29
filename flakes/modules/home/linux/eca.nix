# ECA (editor-code-assistant) server, jailed — spawned by eca-emacs via
# `eca-custom-command` in ~/.emacs.d/apps/dl-eca.el.
#
# On home.packages (not the ~/.emacs.d devshell) so Emacs finds it from any
# buffer, independent of direnv. Emacs launches it with cwd = the workspace
# root; `mount-cwd` binds that root at its host path too, because eca-emacs
# hands the server absolute host paths (the jail's /workspace/<name> mount
# alone would not resolve them). Config is read-only, cache (chat db) is
# read-write, both from the real home rather than the jail's persisted one.
{
  inputs,
  pkgs,
  ...
}: let
  jailLib = inputs.agents.lib.${pkgs.stdenv.hostPlatform.system}.mkJailedAgents {};
in {
  home.packages = [
    (jailLib.makeJailedEca {
      profile = "specDev";
      apiKeys = [
        "OPENROUTER_API_KEY"
        "DEEPSEEK_API_KEY"
      ];
      extraOptions = with jailLib.combinators; [
        mount-cwd
        (try-readonly (noescape "~/.config/eca"))
        (try-readwrite (noescape "~/.cache/eca"))
      ];
    })
  ];
}
