let
  pkgs = import <nixpkgs> {};
  mainPkgs = with pkgs; [
    uv
    ruff
    pylint
    python314
  ];

  pyPackages = with pkgs.python314Packages; [
    lsp-tree-sitter
    python-language-server
    python-lsp-ruff
    python-lsp-jsonrpc
    flake8
    isort
    black
  ];
in
  pkgs.mkShell {
    packages = mainPkgs ++ pyPackages;

    shellHook = ''
    '';
  }
