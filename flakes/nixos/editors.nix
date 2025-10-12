{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    ## editors
    # neovim-gtk
    # emacs-gtk
    obsidian
    code-cursor
    vscode
    zed-editor
    xed-editor
    joplin
    claude-code
    # zim
    # kdePackages.kate
    lapce
    # saber
    # sublime4
    marktext
    apostrophe
  ];
}
