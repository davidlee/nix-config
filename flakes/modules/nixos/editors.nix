{...}: {
  flake.nixosModules.editors = {
    pkgs,
    inputs,
    ...
  }: {
    environment.systemPackages = with pkgs; [
      inputs.helix.packages.x86_64-linux.default
      obsidian
      code-cursor
      vscode
      zed-editor
      xed-editor
      joplin
      claude-code
      lapce
      marktext
      apostrophe
      # zim
      # kdePackages.kate
      # saber
      # sublime4
      # neovim-gtk
      # emacs-gtk
    ];
  };
}
