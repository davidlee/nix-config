{ inputs, username, pkgs, ...}: {

  # keep our vim config as plain old lua files because I'm not a masochist -
  # this is just for plugin dependencies

  programs.neovim = {
    enable = true;
    # defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    # withNodeJs = true;
    # withPython3 = true;
    # withRuby = true;
  };

  home.packages = with pkgs; [
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
  ];
 
}
