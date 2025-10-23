{
  pkgs,
  outputs,
  ...
}: {
  imports = [
    outputs.darwinModules.cliPackages
  ];

  environment.systemPackages = with pkgs; [
    ## mac only
    darwin.trash
    jankyborders
    skhd
    yabai
    shortcat
    # emacs-macport # insecure

    ## not shared for other reasons
    rustup
  ];
}
