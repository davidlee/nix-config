{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    ## text editors
    # helix - use overlay
    kakoune
    kakoune-lsp
    kakoune-cr
    neovim
    sc-im # er, spreadsheet
    wordgrinder

    ## notes / knowledge base
    kb
    nb
    tpnote
    tui-journal
  ];
}
