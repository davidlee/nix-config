_: {
  flake.homeModules.bough = {
    inputs,
    pkgs,
    ...
  }: let
    vk = inputs.bough.packages.${pkgs.system};
  in {
    home.packages = [
      vk.bough
      vk.arbourd
      vk.arbour
    ];

    systemd.user.services.arbourd = {
      Unit = {
        Description = "arbourd — task tree daemon";
        After = ["postgresql.service"];
      };
      Service = {
        ExecStart = "${vk.arbourd}/bin/arbourd run --database-url \"postgres:///corpus\"";
        Restart = "on-failure";
        RestartSec = 5;
      };
      Install = {
        WantedBy = ["default.target"];
      };
    };
  };
}
