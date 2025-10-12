{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    ## text editors
    # helix REPLACED w edge
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
