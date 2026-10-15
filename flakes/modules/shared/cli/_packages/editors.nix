{pkgs, ...}: {
  common = with pkgs; [
    # lapce # gui editor
    wordgrinder
  ];
  linuxHome = with pkgs; [
    kakoune
    kakoune-lsp
    kakoune-cr
    micro-with-wl-clipboard
    kb
    nb
    tpnote
    tui-journal
    emacs-all-the-icons-fonts
  ];
}
