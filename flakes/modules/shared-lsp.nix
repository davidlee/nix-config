{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    ## editor platforms: LSP / treesitter
    # tree-sitter
    # lsp-ai
    # simple-completion-language-server
    # dot-language-server
    # yaml-language-server
    # tooling-language-server

    # docker-language-server
    # bash-language-server
    # vim-language-server
    # just-lsp
    # postgres-lsp
    # typos-lsp
    # htmx-lsp
    # jq-lsp
    # fish-lsp
    # ctags-lsp
    # ruby-lsp
    #
    # python3Packages.python-lsp-server
    # python3Packages.python-lsp-ruff
    # python3Packages.python-lsp-jsonrpc
    # python3Packages.python-lsp-black
  ];
}
