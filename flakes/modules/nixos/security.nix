{config, ...}: {
  # Docker on this flake is rootless only (features/virt.nix, virt.docker).
  # Unconditional, so it also holds when virt.docker is not selected.
  assertions = [
    {
      assertion = !config.virtualisation.docker.enable;
      message = "virtualisation.docker.enable: the rootful docker daemon is refused; docker here is rootless only (virt.docker).";
    }
  ];

  security = {
    # required for cursor sandboxing
    # unprivilegedUsernsClone = true;
    rtkit.enable = true;
    polkit.enable = true;

    sudo = {
      enable = true;
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
