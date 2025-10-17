_: {
  flake.nixosModules.security = {pkgs, ...}: {
    security = {
      rtkit.enable = true;
      polkit.enable = true;

      sudo = {
        enable = true;
        extraRules = [
          {
            groups = ["wheel"];
            commands = [
              {
                command = "${pkgs.nix}/bin/rtcwake *";
                options = ["NOPASSWD" "SETENV"];
              }
            ];
          }
          {
            groups = ["wheel"];
            commands = ["ALL"];
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
  };
}
