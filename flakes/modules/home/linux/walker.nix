# Walker launcher, with its elephant backend. The HM module, not the NixOS one:
# only this one provides `runAsService` (a systemd user unit).
{inputs, ...}: {
  imports = [inputs.walker.homeManagerModules.default];

  programs.walker = {
    enable = true;
    runAsService = true;
    # theme.name = "noctalia";
  };
}
