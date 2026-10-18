# Outer profile for the user's own Linux machines (DEC-033): personal, plus the
# Linux-only personal features. Sets defaults only (mkDefault), so a host can
# override any of them with a plain definition.
{lib, ...}: {
  imports = [./personal.nix];

  feature.satan.harness.enable = lib.mkDefault true;
  feature.satan.patcher.enable = lib.mkDefault true;
  feature.satan.attrd.enable = lib.mkDefault true;
  feature.satan.runner.enable = lib.mkDefault true;
  feature.attention.behaviour.enable = lib.mkDefault true;
  feature.attention.nudge.enable = lib.mkDefault true;
  feature.attention.goad.enable = lib.mkDefault true;
  feature.media.spotify.enable = lib.mkDefault true;
  feature.agents.registry.enable = lib.mkDefault true;
  feature.agents.gateway.enable = lib.mkDefault true;
  feature.agents.eca.enable = lib.mkDefault true;
  feature.agents.chatgpt.enable = lib.mkDefault true;
  feature.net.tailscale.enable = lib.mkDefault true;
  feature.services.ssh.enable = lib.mkDefault true;
  feature.files.locate.enable = lib.mkDefault true;
  # satan.patcher and satan.attrd require it; a profile only defaults it
  # (ADR-001 D4).
  feature.services.postgresql.enable = lib.mkDefault true;
}
