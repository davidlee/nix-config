
{inputs, pkgs, ...}: {
  services = {
    caddy = {
      enable = true;
      acmeCA = "https://acme-v02.api.letsencrypt.org/directory";
    };
    virtualHosts."localhost".extraConfig = ''
      respond "Hey, kid."
    '';
  };
}
