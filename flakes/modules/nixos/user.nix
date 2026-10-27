{
  pkgs,
  username,
  ...
}: {
  # Root and default-shell users get NixOS's bash (DEC-042).
  # The user's login shell is set by the feature that owns it, beside its
  # system setup: terminal.zsh now. To change it, move the `shell =` line to
  # another shell's feature (features/terminal.nix) and select that feature.
  # Without one, the user gets bash too.
  users.mutableUsers = true; # can do without password being clobbered
  users.users = {
    "${username}" = {
      homeMode = "755";
      isNormalUser = true;
      description = "David Lee";
      extraGroups = ["networkmanager" "wheel"];
      home = "/home/${username}";
      packages = [
        pkgs.home-manager
      ];
    };
  };
}
