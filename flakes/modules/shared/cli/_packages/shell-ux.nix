{
  pkgs,
  lib,
  ...
}: {
  ## shell prompt / completion / fuzzy-nav / session tools
  common = with pkgs;
    [
      starship
      carapace
      fzf
    ]
    # atuin 18.23.0 is not cached for aarch64-darwin (ISS-007); position kept
    # so Linux home.packages order is unchanged.
    ++ lib.optional stdenv.hostPlatform.isLinux atuin
    ++ [
      zoxide
      tmux
      zmx # or this
      skim # $ sk

      # abduco # shell persist
      # dvtm # + abduco (suckless)
      # shpool # vs abduco . has a service too
      # sesh  # temporarily broken transitive dep: (go-mockery)
    ];
}
