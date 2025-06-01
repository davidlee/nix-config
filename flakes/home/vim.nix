{
  inputs,
  username,
  pkgs,
  lib,
  ...
}:
{

  # keep our vim config as plain old lua files because I'm not a masochist -
  # this is just for plugin dependencies
  #
  # https://github.com/LazyVim/LazyVim/discussions/1972

  programs.neovim = {
    enable = true;
    defaultEditor = true;

    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    withNodeJs = true;
    withPython3 = true;
    withRuby = true;

    extraPackages = with pkgs; [
      lua-language-server
      stylua
      ripgrep
    ];

    # extraLuaPackages =

    plugins = with pkgs.vimPlugins; [
      lazy-nvim
    ];
  };

  home.packages = with pkgs; [
    stylua
    luarocks
    tectonic
    ast-grep
    imagemagick
    lua5_1
    typescript-language-server
    vscode-langservers-extracted
    emmet-language-server
    nixd
    nixpkgs-fmt
    ruff
    python313Packages.jedi-language-server
    fzf
    lua-language-server
    gh
    gcc
    prettierd
    vimPlugins.LazyVim
    # vimPlugins.vim-prettier
    # vimPlugins.vim-markdown-toc
    markdownlint-cli2
    rubocop

    shfmt
  ];

}
