{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nix-stable.url = "github:nixos/nixpkgs/nixos-24.11";
    zed.url = "github:zed-industries/zed";
    import-tree.url = "github:vic/import-tree";

    antigravity-nix = {
      url = "github:jacopone/antigravity-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {nixpkgs, ...}: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};

    guiApps =
      import ./pkg/ai.nix {
        inherit inputs;
        inherit pkgs;
      }
      ++ import ./pkg/browsers.nix {inherit pkgs;}
      ++ import ./pkg/daw.nix {inherit pkgs;}
      ++ import ./pkg/editors.nix {inherit pkgs;}
      ++ import ./pkg/office.nix {inherit pkgs;};

    # Build patched .desktop files with fully qualified Exec= paths
    desktopFiles = pkgs.runCommandLocal "gui-desktop-files" {} (
      ''
        mkdir -p $out
      ''
      + builtins.concatStringsSep "\n" (map (pkg: ''
          for f in ${pkg}/share/applications/*.desktop; do
            [ -f "$f" ] || continue
            sed -E \
              -e 's|^Exec=([^/])|Exec=${pkg}/bin/\1|' \
              -e 's|^TryExec=([^/])|TryExec=${pkg}/bin/\1|' \
              -e 's|^Icon=([^/])|Icon=${pkg}/share/icons/\1|' \
              "$f" > "$out/$(basename "$f")"
          done
        '')
        guiApps)
    );
  in {
    devShells.${system}.default = pkgs.mkShell {
      packages = guiApps;
      shellHook = ''
        _desktop_dir="$HOME/.local/share/applications/gui"
        mkdir -p "$_desktop_dir"
        # remove stale links
        find "$_desktop_dir" -maxdepth 1 -type l -delete 2>/dev/null
        # link patched desktop files
        for f in ${desktopFiles}/*.desktop; do
          [ -f "$f" ] && ln -sf "$f" "$_desktop_dir/"
        done
      '';
    };
  };
}
