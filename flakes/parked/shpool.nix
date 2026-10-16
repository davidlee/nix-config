# parked (DEC-043): emacs uses zmx (IMP-001); not imported.
{pkgs, ...}: {
  systemd.user.services.shpool = {
    Unit = {
      Description = "shpool - shell session pool";
      After = ["default.target"];
    };
    Service = {
      ExecStart = "${pkgs.shpool}/bin/shpool daemon";
      Restart = "on-failure";
      RestartSec = "5s";
    };
    Install.WantedBy = ["default.target"];
  };
}
