_: {
  flake.nixosModules.sshd = {hostname, ...}: {
    services = {
      fail2ban.enable = true;
      openssh = {
        enable = true;
        settings = {
          GatewayPorts = "yes";
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
          X11Forwarding = false;
          PermitRootLogin = "no";
          UseDns = true;
        };
      };
    };
  };
}
