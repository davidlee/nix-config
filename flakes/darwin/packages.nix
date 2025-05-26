{pkgs, ...}: {
  
  imports = [
    ../modules/shared-packages.nix   
    ../modules/shared-development.nix
    ../modules/shared-tui.nix
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
