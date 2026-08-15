{
  pkgs,
  username,
  ...
}: {
  security = {
    # required for cursor sandboxing
    unprivilegedUsernsClone = true;
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
        # Read-only, and it is what lets ~/dev/microvm-spike's capsule-host
        # verify that the FORWARD drop on the tap (network.nix) is actually
        # loaded, rather than trusting that the host config still says so.
        # Without this the check degrades to "unverifiable", which is
        # fail-closed once forwarding goes live.
        #
        # /run/current-system/sw/bin, not a store path: the checking script
        # lives in another flake with its own nixpkgs pin and has to name the
        # same string this rule does. sudo matches the command literally,
        # arguments included, so this grants exactly this one read.
        {
          users = [username];
          commands = [
            {
              command = "/run/current-system/sw/bin/nft list table inet capsule-forward";
              options = ["NOPASSWD"];
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
