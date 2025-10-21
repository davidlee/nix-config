_: {
  flake.nixosModules.emacs = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      emacs
      # pkgs.emacs.pkgs.withPackages
      # (epkgs: [
      #   (epkgs.treesit-grammars.with-grammars (grammars: [grammars.tree-sitter-bash]))
      # ])
    ];
  };
}
