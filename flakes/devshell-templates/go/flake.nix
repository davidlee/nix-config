{
  description = "A basic flake with a shell";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.systems.url = "github:nix-systems/default";
  inputs.flake-utils = {
    url = "github:numtide/flake-utils";
    inputs.systems.follows = "systems";
  };

  outputs = {
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};

        # Common dependencies for all platforms
        commonPackages = with pkgs; [
          # Go
          go # compiler
          gopls # language server
          delve # debugger
          gofumpt # strict formatter
          golangci-lint # linter

          # treesitter
          tree-sitter
          # grammars
          python312Packages.tree-sitter-grammars.tree-sitter-go
        ];

        # Linux-specific dependencies (amd64)
        linuxPackages = with pkgs;
          lib.optionals stdenv.isLinux [
            # zed-editor
          ];

        # Darwin-specific dependencies
        darwinPackages = with pkgs;
          lib.optionals stdenv.isDarwin [
          ];

        # Linux-specific shell hook
        linuxShellHook =
          if pkgs.stdenv.isLinux
          then ''
          ''
          else "";

        # Darwin-specific shell hook
        darwinShellHook =
          if pkgs.stdenv.isDarwin
          then ''
          ''
          else "";
      in {
        devShells.default = pkgs.mkShell {
          packages = commonPackages ++ linuxPackages ++ darwinPackages;

          shellHook = ''
            ${linuxShellHook}
            ${darwinShellHook}

            # Common shell setup for all platforms
            echo "Development environment loaded for: ${system}"
            echo "Platform: ${
              if pkgs.stdenv.isLinux
              then "Linux"
              else if pkgs.stdenv.isDarwin
              then "Darwin"
              else "Unknown"
            }"
          '';
        };
      }
    );
}
