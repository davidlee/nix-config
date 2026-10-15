{pkgs, ...}: {
  security = {
    # required for cursor sandboxing
    # unprivilegedUsernsClone = true;
    rtkit.enable = true;
    polkit.enable = true;

    sudo = {
      enable = true;
      # ORDER IS SIGNIFICANT: sudoers is last-match-wins
      extraRules = [
        {
          groups = ["wheel"];
          commands = [
            {
              command = "${pkgs.util-linux}/bin/rtcwake";
              options = ["NOPASSWD" "SETENV"];
            }
            {
              command = "/run/current-system/sw/bin/rtcwake";
              options = ["NOPASSWD" "SETENV"];
            }
          ];
        }
      ];
    };

    pam.loginLimits = [
      # allow any user prog to request realtime priority
      {
        domain = "@users";
        item = "rtprio";
        type = "-";
        value = 1;
      }
    ];
    pam.services.greetd.enableGnomeKeyring = true;
  };
}
