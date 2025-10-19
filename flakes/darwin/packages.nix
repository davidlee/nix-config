{
  pkgs,
  outputs,
  ...
}: {
  imports = [
    outputs.darwinModules.fileutils
    outputs.darwinModules.build
    outputs.darwinModules.scm
    outputs.darwinModules.gfx
    outputs.darwinModules.pkg
    outputs.darwinModules.net
    outputs.darwinModules.search
    outputs.darwinModules.shell
    outputs.darwinModules.sec
    outputs.darwinModules.supervisors
    outputs.darwinModules.text
    outputs.darwinModules.tui
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
