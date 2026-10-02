{username, ...}: {
  imports = [
    ../modules/home/shared/zsh.nix
    ../modules/home/shared/nvim-plugins.nix
    ../modules/home/shared/nvim.nix
    ../modules/home/shared/programs.nix
    ../modules/home/shared/emacs.nix
    ../modules/home/shared/cli.nix
    ../modules/home/shared/nushell.nix
  ];

  home = {
    homeDirectory = "/Users/${username}";
    stateVersion = "24.11";
  };

  programs = {
    home-manager.enable = true;
    # HACK: bridge nix-darwin's POSIX PATH setup into a direct Nu login.
    # Nu does not source /etc/profile; env.nu must add Nix paths before
    # vendor hooks/config.nu run. This is an integration gap, not an OS bug.
    # Revisit if nix-darwin/Home Manager provides native Nu PATH setup;
    # remove only after a fresh login finds atuin/zoxide without this block.
    nushell.extraEnv = ''
      $env.PATH = ([
        ($env.HOME | path join ".nix-profile" "bin")
        "/etc/profiles/per-user/${username}/bin"
        "/run/current-system/sw/bin"
        "/nix/var/nix/profiles/default/bin"
      ] | append $env.PATH | uniq)
    '';
    kitty.darwinLaunchOptions = [
      "--listen-on=unix:/tmp/meow"
      "--single-instance"
    ];
  };

  targets.darwin.defaults = {
    # NSGlobalDomain = {
    # };

    # "com.apple.dock" = {
    # };

    # "com.apple.finder" = {
    # };

    # "com.apple.Safari" = {
    # };

    "com.apple.desktopservices".DSDontWriteUSBStores = true;
  };
}
