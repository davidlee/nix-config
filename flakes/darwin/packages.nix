{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    ## mac only
    darwin.trash
    # jankyborders
    # skhd
    # yabai
    shortcat

    ## not shared for other reasons
    rustup
  ];
}
