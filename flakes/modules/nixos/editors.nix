_: {
  flake.nixosModules.editors = {
    pkgs,
    inputs,
    ...
  }: {
    environment.systemPackages = with pkgs; [
      inputs.helix.packages.x86_64-linux.default
      # emacs-gtk
      obsidian
      code-cursor
      vscode
      joplin
      marktext
      apostrophe
      sublime-merge
    ];
  };
}
