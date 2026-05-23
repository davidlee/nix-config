# satan-attrd — SATAN attribute daemon (LISTEN satan_outcome_inbox,
# dispatch §6/§7 deltas, NOTIFY satan_audit_inbox).
#
# Source: ~/dev/satan-attrd (path: input — switch to git+file:// or
# github once stable).
#
# State + artefacts:
#   Postgres DB satan_memory (migrations 0007–0010).
#   No on-disk state beyond DB.
#
# Migrations are NOT auto-applied at boot.  Apply by hand before
# (re)starting the service after a schema change:
#   satan-attrd migrate
#
# Smoke:
#   systemctl --user status satan-attrd
#   journalctl --user -u satan-attrd -f
#   psql -d satan_memory -c 'SELECT count(*) FROM satan_outcome_inbox;'
_: {
  flake.homeModules.satan-attrd = {
    inputs,
    pkgs,
    ...
  }: {
    imports = [inputs.satan-attrd.homeManagerModules.default];

    services.satan-attrd = {
      enable = true;
      package = inputs.satan-attrd.packages.${pkgs.system}.satan-attrd;
    };
  };
}
