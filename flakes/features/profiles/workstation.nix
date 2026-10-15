# Outer profile for a desktop workstation. Sets defaults only (mkDefault), so a
# host that imports it can override any of them with a plain definition.
{lib, ...}: {
  feature.session.snooze.enable = lib.mkDefault true;
}
