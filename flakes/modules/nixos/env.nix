_: {
  environment = {
    variables = {
      NIXOS = "true";
      VISUAL = "hx";
      SSH_ASKPASS_REQUIRE = "prefer";
    };

    # pam_env sets these at login, before the compositor starts, so GUI apps
    # and systemd --user units inherit them - not just login shells.
    # Prepended ahead of the nix profiles; see /etc/pam/environment.
    sessionVariables.PATH = [
      "$HOME/.local/bin"
      "$HOME/.local/bin/scripts"
      "$HOME/.cargo/bin"
      "$HOME/go/bin"
      "$HOME/.pnpm-global/bin"
      "$HOME/.npm-global/bin"
    ];
    pathsToLink = ["/share/zsh"]; # for autocompletion
  };

  # i18n / l10n
  #
  time.timeZone = "Australia/Melbourne";

  i18n.defaultLocale = "en_AU.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_AU.UTF-8";
    LC_IDENTIFICATION = "en_AU.UTF-8";
    LC_MEASUREMENT = "en_AU.UTF-8";
    LC_MONETARY = "en_AU.UTF-8";
    LC_NAME = "en_AU.UTF-8";
    LC_NUMERIC = "en_AU.UTF-8";
    LC_PAPER = "en_AU.UTF-8";
    LC_TELEPHONE = "en_AU.UTF-8";
    LC_TIME = "en_AU.UTF-8";
  };
}
