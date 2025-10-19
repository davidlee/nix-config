_: {
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
      joplin
      lapce
      marktext
      apostrophe
      kakoune
      kakoune-lsp
      kakoune-cr
      wordgrinder
      micro-with-wl-clipboard
      emacsclient-commands
      # zed-editor
      # xed-editor
      # zim
      # kdePackages.kate
      # saber
      # sublime4
      # neovim-gtk
      # emacs-gtk
      # helix - use overlay
      # neovim - nightly
      # sc-im # er, spreadsheet

      ## notes / knowledge base
      kb
      nb
      tpnote
      tui-journal
    ];
  };
}
