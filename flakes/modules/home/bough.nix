_: {
  flake.homeModules.bough = {
    inputs,
    pkgs,
    ...
  }: let
    bh = inputs.bough.packages.${pkgs.system};
  in {
    home.packages = [
      bh.default
    ];

    # systemd.user.services.arbourd = {
    #   Unit = {
    #     Description = "arbourd — task tree daemon";
    #     After = ["postgresql.service"];
    #   };
    #   Service = {
    #     ExecStart = "${vk.arbourd}/bin/arbourd run --database-url \"postgres:///bough_production\"";
    #     Restart = "on-failure";
    #     RestartSec = 5;
    #   };
    #   Install = {
    #     WantedBy = ["default.target"];
    #   };
    # };
  };
}
