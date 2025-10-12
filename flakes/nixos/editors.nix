{
  pkgs,
  inputs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    inputs.helix.packages.x86_64-linux.default
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
